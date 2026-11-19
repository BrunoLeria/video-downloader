import 'dart:io';

import 'package:dio/dio.dart';

class DownloadService {
  static final Dio _dio = Dio();

  static Future<String> downloadFile({
    required String url,
    required String savePath,
    required void Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    final file = File(savePath);
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    await _dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        onProgress(received, total);
      },
      cancelToken: cancelToken,
      options: Options(receiveTimeout: const Duration(minutes: 5)),
      deleteOnError: true,
    );
    return file.path;
  }

  static String formatSize(int bytes) {
    if (bytes <= 0) {
      return '0 KB';
    }
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }
    return '${value.toStringAsFixed(value >= 10 || unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }

  static String formatRemaining(Duration remaining) {
    if (remaining.isNegative || remaining.inSeconds == 0) {
      return '0s';
    }
    if (remaining.inHours >= 1) {
      return '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m';
    }
    if (remaining.inMinutes >= 1) {
      return '${remaining.inMinutes}m ${remaining.inSeconds.remainder(60)}s';
    }
    return '${remaining.inSeconds}s';
  }
}
