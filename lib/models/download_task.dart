import 'package:dio/dio.dart';

class DownloadTask {
  DownloadTask({
    required this.id,
    required this.title,
    required this.platform,
    required this.optionLabel,
    required this.fileName,
    this.status = 'downloading',
    this.progress = 0,
    this.bytesReceived = 0,
    this.totalBytes = 0,
    this.filePath,
    this.errorMessage,
    this.cancelToken,
  });

  final String id;
  final String title;
  final String platform;
  final String optionLabel;
  final String fileName;
  String status;
  double progress;
  int bytesReceived;
  int totalBytes;
  String? filePath;
  String? errorMessage;
  CancelToken? cancelToken;

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';

  DownloadTask copyWith({
    String? id,
    String? title,
    String? platform,
    String? optionLabel,
    String? fileName,
    String? status,
    double? progress,
    int? bytesReceived,
    int? totalBytes,
    String? filePath,
    String? errorMessage,
    CancelToken? cancelToken,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      optionLabel: optionLabel ?? this.optionLabel,
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      bytesReceived: bytesReceived ?? this.bytesReceived,
      totalBytes: totalBytes ?? this.totalBytes,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage ?? this.errorMessage,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }
}
