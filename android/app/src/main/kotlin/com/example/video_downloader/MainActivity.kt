package com.example.video_downloader

import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors
import java.util.regex.Pattern

class MainActivity : FlutterActivity() {
    private val channelName = "video_downloader/instagram"
    private val executor = Executors.newCachedThreadPool()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "extract" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrBlank()) {
                        result.error("INVALID_URL", "A URL do Instagram é obrigatória.", null)
                        return@setMethodCallHandler
                    }
                    val mode = call.argument<String>("mode") ?: "info"
                    executor.execute {
                        try {
                            val payload = extractInstagram(url, mode)
                            runOnUiThread { result.success(payload) }
                        } catch (error: InstagramExtractException) {
                            runOnUiThread {
                                result.error(error.code, error.message, error.details)
                            }
                        } catch (error: Exception) {
                            runOnUiThread {
                                result.error(
                                    "EXTRACTION_FAILED",
                                    error.message ?: "Falha ao extrair o Instagram.",
                                    null,
                                )
                            }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun extractInstagram(rawUrl: String, mode: String): Map<String, Any?> {
        val uri = Uri.parse(rawUrl)
        val host = uri.host?.lowercase() ?: ""
        if (host != "instagram.com" && !host.endsWith(".instagram.com")) {
            throw InstagramExtractException(
                "INVALID_URL",
                "A URL não pertence ao Instagram.",
            )
        }

        val connection = URL(rawUrl).openConnection() as HttpURLConnection
        connection.requestMethod = "GET"
        connection.connectTimeout = 30_000
        connection.readTimeout = 60_000
        connection.instanceFollowRedirects = true
        connection.setRequestProperty(
            "User-Agent",
            "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 " +
                "(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
        )
        connection.setRequestProperty(
            "Accept",
            "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        )
        connection.setRequestProperty("Accept-Language", "pt-BR,pt;q=0.9,en;q=0.8")
        connection.setRequestProperty("Referer", "https://www.instagram.com/")

        val status = connection.responseCode
        if (status == 401 || status == 403) {
            throw InstagramExtractException(
                "LOGIN_REQUIRED",
                "O Instagram bloqueou o acesso anônimo. Use um URL público ou atualize o extrator.",
                mapOf("status" to status),
            )
        }
        if (status == 429) {
            throw InstagramExtractException(
                "RATE_LIMITED",
                "O Instagram limitou temporariamente as solicitações.",
                mapOf("status" to status),
            )
        }
        if (status !in 200..299) {
            throw InstagramExtractException(
                "HTTP_ERROR",
                "O Instagram respondeu com HTTP $status.",
                mapOf("status" to status),
            )
        }

        val html = connection.inputStream.bufferedReader().use { it.readText() }
        connection.disconnect()

        val videoUrls = mutableSetOf<String>()
        for (match in Regex(
            """(?i)(?:["']video_url["']\s*:\s*["']|<meta[^>]+property=["']og:video(?::secure_url)?["'][^>]+content=["'])([^"'<]+)""",
        ).findAll(html)) {
            val candidate = decodeHtml(match.groupValues[1])
            if (candidate.startsWith("http")) {
                videoUrls.add(candidate.replace("\\/", "/"))
            }
        }

        val ogVideoPattern = Pattern.compile(
            """<meta[^>]+(?:property|name)=["'](?:og:video|og:video:secure_url)["'][^>]+content=["']([^"']+)["']""",
            Pattern.CASE_INSENSITIVE,
        )
        val ogVideoMatcher = ogVideoPattern.matcher(html)
        while (ogVideoMatcher.find()) {
            val candidate = decodeHtml(ogVideoMatcher.group(1))
            if (candidate.startsWith("http")) {
                videoUrls.add(candidate.replace("\\/", "/"))
            }
        }

        val ogImage = metaContent(html, "og:image")
        val title = metaContent(html, "og:title")?.trim()
            ?.takeIf { it.isNotEmpty() }
            ?: "Mídia do Instagram"
        val description = metaContent(html, "og:description")?.trim()
            ?.takeIf { it.isNotEmpty() }
            ?: "Instagram"

        if (mode == "options") {
            val options = videoUrls.map { videoUrl ->
                mapOf(
                    "type" to "video",
                    "format" to "mp4",
                    "quality" to "Original",
                    "url" to videoUrl,
                    "estimatedBytes" to null,
                    "sizeLabel" to null,
                )
            }
            if (options.isEmpty()) {
                throw InstagramExtractException(
                    "NO_MEDIA",
                    "Nenhum URL de vídeo foi encontrado nesta página pública.",
                )
            }
            return mapOf("options" to options)
        }

        val durationSeconds = Regex(
            """"(?:duration|duration_seconds)"\s*:\s*([0-9]+(?:\.[0-9]+)?)""",
        ).find(html)?.groupValues?.get(1)?.toDoubleOrNull()?.toInt() ?: 0

        return mapOf(
            "title" to title,
            "author" to description,
            "thumbnail" to (ogImage ?: ""),
            "durationSeconds" to durationSeconds,
        )
    }

    private fun metaContent(html: String, property: String): String? {
        val patterns = listOf(
            """<meta[^>]+property=["']${Pattern.quote(property)}["'][^>]+content=["']([^"']+)["']""",
            """<meta[^>]+name=["']${Pattern.quote(property)}["'][^>]+content=["']([^"']+)["']""",
            """<meta[^>]+content=["']([^"']+)["'][^>]+(?:property|name)=["']${Pattern.quote(property)}["']""",
        )
        for (pattern in patterns) {
            val match = Regex(pattern, RegexOption.IGNORE_CASE).find(html)
            if (match != null) {
                return decodeHtml(match.groupValues[1]).replace("&amp;", "&")
            }
        }
        return null
    }

    private fun decodeHtml(value: String): String {
        var decoded = value
            .replace("\\u0026", "&")
            .replace("\\u002F", "/")
            .replace("\\/", "/")
            .replace("&quot;", "\"")
            .replace("&#x27;", "'")
            .replace("&apos;", "'")
            .replace("&amp;", "&")

        val unicode = Regex("""\\u([0-9A-Fa-f]{4})""")
        decoded = unicode.replace(decoded) {
            it.groupValues[1].toInt(16).toChar().toString()
        }
        return decoded
    }
}

private class InstagramExtractException(
    val code: String,
    message: String,
    val details: Any? = null,
) : Exception(message)
