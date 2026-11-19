import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
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
