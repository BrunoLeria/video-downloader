import 'package:video_downloader/models/media_info.dart';
import 'package:video_downloader/models/media_option.dart';

abstract class MediaExtractor {
  bool canHandle(Uri url);

  Future<MediaInfo> fetchInfo(Uri url);

  Future<List<MediaOption>> listOptions(MediaInfo info);
}
