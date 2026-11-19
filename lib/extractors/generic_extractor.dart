import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:video_downloader/extractors/media_extractor.dart';
import 'package:video_downloader/models/media_info.dart';
import 'package:video_downloader/models/media_option.dart';

class GenericExtractor implements MediaExtractor {
  GenericExtractor({
    required this.backendUrl,
    this.platform = SupportedPlatform.generic,
  });

  final String backendUrl;
  final SupportedPlatform platform;

  @override
  bool canHandle(Uri url) => true;

  @override
  Future<MediaInfo> fetchInfo(Uri url) async {
    final response = await Dio().post(
      backendUrl,
      data: jsonEncode({
        'url': url.toString(),
        'mode': 'info',
        'platform': platform.name,
      }),
      options: Options(
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 90),
      ),
    );
    final map = response.data as Map<String, dynamic>;
    return MediaInfo(
      platform: platform,
      title: map['title'] as String? ?? 'Mídia sem título',
      author: map['author'] as String? ?? 'Desconhecido',
      thumbnail: map['thumbnail'] as String? ?? '',
      duration: Duration(
        seconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      ),
      originalUrl: url.toString(),
    );
  }

  @override
  Future<List<MediaOption>> listOptions(MediaInfo info) async {
    final response = await Dio().post(
      backendUrl,
      data: jsonEncode({
        'url': info.originalUrl,
        'mode': 'options',
        'platform': platform.name,
      }),
      options: Options(
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 90),
      ),
    );

    final payload = response.data as Map<String, dynamic>;
    final list = (payload['options'] as List<dynamic>? ?? const <dynamic>[]);
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return MediaOption(
        type: map['type'] == 'audio'
            ? MediaType.audio
            : map['type'] == 'video+audio'
            ? MediaType.videoAudio
            : MediaType.video,
        format: map['format'] as String? ?? 'mp4',
        quality: map['quality'] as String? ?? 'Padrão',
        url: map['url'] as String? ?? '',
        estimatedBytes: (map['estimatedBytes'] as num?)?.toInt(),
        sizeLabel: map['sizeLabel'] as String?,
      );
    }).toList();
  }
}
