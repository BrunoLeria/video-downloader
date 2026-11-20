import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debug report JSON is replayable', () {
    final data = jsonDecode('''{
      "schemaVersion": 1,
      "originalUrl": "https://www.instagram.com/reel/ABC123/",
      "normalizedUrl": "https://www.instagram.com/reel/ABC123/",
      "platform": "instagram",
      "backendUrl": "http://127.0.0.1:8000",
      "error": {"message": "connection timeout", "stackTrace": ""}
    }''');

    expect(data['originalUrl'], contains('instagram.com/reel/'));
    expect(data['normalizedUrl'], isNotEmpty);
    expect(data['backendUrl'], contains('8000'));
  });

  group('Backend JSON contract', () {
    test('contem campos esperados', () {
      final data = jsonDecode('''{
        "title": "Example",
        "author": "Author",
        "thumbnail": "https://example.com/thumb.jpg",
        "durationSeconds": 120,
        "options": [{
          "type": "video",
          "format": "mp4",
          "quality": "720p",
          "estimatedBytes": 1000,
          "sizeLabel": "1.0 MB",
          "url": "https://example.com/file.mp4"
        }]
      }''');

      expect(data['title'], isA<String>());
      expect(data['author'], isA<String>());
      expect(data['options'], isA<List>());
      expect(data['options'][0]['url'], contains('http'));
    });
  });
}
