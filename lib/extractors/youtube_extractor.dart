import 'package:video_downloader/extractors/media_extractor.dart';
import 'package:video_downloader/models/media_info.dart';
import 'package:video_downloader/models/media_option.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeExtractor implements MediaExtractor {
  final YoutubeExplode _youtube = YoutubeExplode();

  static String _extractVideoId(Uri url) {
    final queryId = url.queryParameters['v'];
    if (queryId != null && queryId.trim().isNotEmpty) {
      return queryId;
    }

    final pathSegments = url.pathSegments;
    if (pathSegments.isEmpty) {
      return '';
    }

    if (pathSegments.first == 'shorts' && pathSegments.length > 1) {
      return pathSegments[1];
    }

    if (pathSegments.first == 'watch' && pathSegments.length > 1) {
      return pathSegments[1];
    }

    for (final segment in pathSegments) {
      if (segment.isNotEmpty && segment != 'shorts' && segment != 'watch') {
        return segment;
      }
    }

    return '';
  }

  @override
  bool canHandle(Uri url) {
    final host = url.host.toLowerCase();
    return host.contains('youtube.com') || host.contains('youtu.be');
  }

  @override
  Future<MediaInfo> fetchInfo(Uri url) async {
    final id = _extractVideoId(url);
    if (id.isEmpty) {
      throw const FormatException('URL do YouTube inválida.');
    }

    final video = await _youtube.videos.get(id);
    return MediaInfo(
      platform: SupportedPlatform.youtube,
      title: video.title,
      author: video.author,
      thumbnail: video.thumbnails.highResUrl,
      duration: video.duration ?? const Duration(),
      originalUrl: url.toString(),
    );
  }

  @override
  Future<List<MediaOption>> listOptions(MediaInfo info) async {
    final url = Uri.tryParse(info.originalUrl);
    if (url == null) {
      return const [];
    }

    final id = _extractVideoId(url);
    if (id.isEmpty) {
      return const [];
    }

    final manifest = await _youtube.videos.streams.getManifest(id);
    final options = <MediaOption>[];

    for (final stream in manifest.muxed.take(8)) {
      final format = stream.container.name.toUpperCase();
      options.add(
        MediaOption(
          type: MediaType.video,
          format: format.toLowerCase(),
          quality: stream.qualityLabel,
          url: stream.url.toString(),
          estimatedBytes: stream.size.totalBytes,
          sizeLabel: '${stream.size.totalBytes ~/ (1024 * 1024)} MB',
        ),
      );
    }

    for (final stream in manifest.audioOnly.take(4)) {
      options.add(
        MediaOption(
          type: MediaType.audio,
          format: stream.container.name,
          quality: 'Audio',
          url: stream.url.toString(),
          estimatedBytes: stream.size.totalBytes,
          sizeLabel: '${stream.size.totalBytes ~/ (1024 * 1024)} MB',
        ),
      );
    }

    return options;
  }
}
