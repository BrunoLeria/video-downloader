import 'package:flutter_test/flutter_test.dart';
import 'package:video_downloader/services/url_normalizer.dart';

void main() {
  group('UrlNormalizer', () {
    test('normaliza URL do YouTube curto', () {
      final normalized = UrlNormalizer.normalize('https://youtu.be/dQw4w9WgXcQ');
      expect(normalized, contains('youtube.com/watch'));
      expect(normalized, contains('dQw4w9WgXcQ'));
    });

    test('normaliza URL do YouTube Shorts', () {
      final normalized = UrlNormalizer.normalize('https://youtube.com/shorts/YQwXoMUNX3U?is=4ooYpsy34s_hC8OY');
      expect(normalized, contains('youtube.com/watch'));
      expect(normalized, contains('YQwXoMUNX3U'));
    });

    test('normaliza URL do Shorts em youtu.be', () {
      final normalized = UrlNormalizer.normalize('https://youtu.be/shorts/YQwXoMUNX3U');
      expect(normalized, contains('youtube.com/watch'));
      expect(normalized, contains('YQwXoMUNX3U'));
    });

    test('mantém URL do Instagram', () {
      const raw = 'https://www.instagram.com/reel/ABC123/';
      expect(UrlNormalizer.normalize(raw), raw);
    });

    test('adiciona scheme quando necessário', () {
      expect(
        UrlNormalizer.normalize('www.youtube.com/watch?v=test123'),
        contains('https://www.youtube.com/watch?v=test123'),
      );
    });
  });
}
