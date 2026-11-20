import 'package:flutter_test/flutter_test.dart';
import 'package:video_downloader/models/debug_report.dart';

void main() {
  test('serializes URL and replay fields for export', () {
    final report = DebugReport(
      id: 7,
      createdAt: DateTime.utc(2026, 11, 20),
      originalUrl: 'https://www.instagram.com/reel/ABC123/',
      normalizedUrl: 'https://www.instagram.com/reel/ABC123/',
      platform: 'instagram',
      backendUrl: 'http://127.0.0.1:8000',
      errorMessage: 'connection timeout',
      stackTrace: 'DioException',
      appVersion: '1.0.0+1',
      device: const {'platform': 'android', 'model': 'Test phone'},
    );

    final json = report.toJson();

    expect(json['schemaVersion'], 1);
    expect(json['originalUrl'], contains('ABC123'));
    expect(json['normalizedUrl'], contains('instagram.com'));
    expect(json['backendUrl'], contains('8000'));
    expect((json['error'] as Map)['message'], 'connection timeout');
  });
}
