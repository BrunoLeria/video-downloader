import 'package:flutter_test/flutter_test.dart';
import 'package:video_downloader/extractors/instagram_extractor.dart';
import 'package:video_downloader/models/media_info.dart';

void main() {
  group('InstagramExtractor', () {
    final extractor = InstagramExtractor(backendUrl: 'https://backend.test/extract');

    test('aceita URLs do domínio e subdomínios do Instagram', () {
      expect(
        extractor.canHandle(Uri.parse('https://www.instagram.com/reel/abc123')),
        isTrue,
      );
      expect(
        extractor.canHandle(Uri.parse('https://instagram.com/p/abc123')),
        isTrue,
      );
    });

    test('não aceita domínios que apenas contenham instagram.com', () {
      expect(
        extractor.canHandle(Uri.parse('https://notinstagram.com/reel/abc123')),
        isFalse,
      );
    });

    test('identifica o resultado como Instagram', () {
      expect(extractor.platform, SupportedPlatform.instagram);
    });
  });
}
