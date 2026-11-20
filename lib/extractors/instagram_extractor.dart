import 'dart:io';

import 'package:flutter/services.dart';
import 'package:video_downloader/extractors/generic_extractor.dart';
import 'package:video_downloader/extractors/media_extractor.dart';
import 'package:video_downloader/models/media_info.dart';
import 'package:video_downloader/models/media_option.dart';

class InstagramExtractor implements MediaExtractor {
  InstagramExtractor({required this.backendUrl})
    : _fallback = GenericExtractor(
        backendUrl: backendUrl,
        platform: SupportedPlatform.instagram,
      );

  final String backendUrl;
  final GenericExtractor _fallback;
  SupportedPlatform get platform => SupportedPlatform.instagram;
  static const _channel = MethodChannel('video_downloader/instagram');

  @override
  bool canHandle(Uri url) {
    final host = url.host.toLowerCase();
    return host == 'instagram.com' || host.endsWith('.instagram.com');
  }

  @override
  Future<MediaInfo> fetchInfo(Uri url) async {
    if (!Platform.isAndroid) {
      return _fallback.fetchInfo(url);
    }

    try {
      final map = await _channel.invokeMapMethod<String, dynamic>('extract', {
        'url': url.toString(),
        'mode': 'info',
      });
      if (map == null) {
        throw const FormatException(
          'O extrator Android não retornou informações.',
        );
      }
      return MediaInfo(
        platform: SupportedPlatform.instagram,
        title: map['title'] as String? ?? 'Mídia do Instagram',
        author: map['author'] as String? ?? 'Desconhecido',
        thumbnail: map['thumbnail'] as String? ?? '',
        duration: Duration(
          seconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
        ),
        originalUrl: url.toString(),
      );
    } on PlatformException catch (error) {
      throw FormatException(
        error.message?.isNotEmpty == true
            ? error.message!
            : 'Falha ao extrair o Instagram.',
      );
    }
  }

  @override
  Future<List<MediaOption>> listOptions(MediaInfo info) async {
    final url = Uri.tryParse(info.originalUrl);
    if (url == null) {
      return const [];
    }
    if (!Platform.isAndroid) {
      return _fallback.listOptions(info);
    }

    try {
      final map = await _channel.invokeMapMethod<String, dynamic>('extract', {
        'url': url.toString(),
        'mode': 'options',
      });
      final list = map?['options'] as List<dynamic>? ?? const [];
      return list
          .whereType<Map>()
          .map((item) {
            final option = Map<String, dynamic>.from(item);
            return MediaOption(
              type: MediaType.video,
              format: option['format'] as String? ?? 'mp4',
              quality: option['quality'] as String? ?? 'Original',
              url: option['url'] as String? ?? '',
              estimatedBytes: (option['estimatedBytes'] as num?)?.toInt(),
              sizeLabel: option['sizeLabel'] as String?,
            );
          })
          .where((option) => option.url.isNotEmpty)
          .toList();
    } on PlatformException catch (error) {
      throw FormatException(
        error.message?.isNotEmpty == true
            ? error.message!
            : 'Falha ao listar opções do Instagram.',
      );
    }
  }
}
