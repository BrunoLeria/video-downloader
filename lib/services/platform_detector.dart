import 'package:video_downloader/models/media_info.dart';

class PlatformDetector {
  static SupportedPlatform detect(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return SupportedPlatform.unsupported;
    }

    final host = uri.host.toLowerCase();
    if (host.contains('youtube.com') || host.contains('youtu.be')) {
      return SupportedPlatform.youtube;
    }
    if (host.contains('instagram.com')) {
      return SupportedPlatform.instagram;
    }
    return SupportedPlatform.generic;
  }
}
