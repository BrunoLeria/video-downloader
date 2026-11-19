import 'package:video_downloader/models/media_info.dart';
import 'package:video_downloader/extractors/generic_extractor.dart';

class InstagramExtractor extends GenericExtractor {
  InstagramExtractor({required super.backendUrl})
      : super(platform: SupportedPlatform.instagram);

  @override
  bool canHandle(Uri url) {
    final host = url.host.toLowerCase();
    return host == 'instagram.com' || host.endsWith('.instagram.com');
  }
}
