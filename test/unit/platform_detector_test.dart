import 'package:flutter_test/flutter_test.dart';
import 'package:video_downloader/models/media_info.dart';
import 'package:video_downloader/services/platform_detector.dart';

void main() {
  group('PlatformDetector', () {
    test('detecta YouTube', () {
      expect(PlatformDetector.detect('https://www.youtube.com/watch?v=abc'), SupportedPlatform.youtube);
    });

    test('detecta Instagram', () {
      expect(PlatformDetector.detect('https://www.instagram.com/reel/abc123/'), SupportedPlatform.instagram);
    });

    test('detecta generico para outras URLs', () {
      expect(PlatformDetector.detect('https://example.com/video.mp4'), SupportedPlatform.generic);
    });
  });
}
