import 'dart:convert';

class DebugReport {
  const DebugReport({
    required this.id,
    required this.createdAt,
    required this.originalUrl,
    required this.normalizedUrl,
    required this.platform,
    required this.backendUrl,
    required this.errorMessage,
    required this.stackTrace,
    required this.appVersion,
    required this.device,
  });

  final int? id;
  final DateTime createdAt;
  final String originalUrl;
  final String normalizedUrl;
  final String platform;
  final String backendUrl;
  final String errorMessage;
  final String stackTrace;
  final String appVersion;
  final Map<String, dynamic> device;

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'id': id,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'originalUrl': originalUrl,
    'normalizedUrl': normalizedUrl,
    'platform': platform,
    'backendUrl': backendUrl,
    'error': {'message': errorMessage, 'stackTrace': stackTrace},
    'app': {'version': appVersion},
    'device': device,
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, dynamic> toMap() => {'id': id, ...toJson()};

  factory DebugReport.fromMap(Map<String, dynamic> map) {
    final error = map['error'] is Map
        ? Map<String, dynamic>.from(map['error'] as Map)
        : const <String, dynamic>{};
    final app = map['app'] is Map
        ? Map<String, dynamic>.from(map['app'] as Map)
        : const <String, dynamic>{};
    final device = map['device'] is Map
        ? Map<String, dynamic>.from(map['device'] as Map)
        : const <String, dynamic>{};

    return DebugReport(
      id: map['id'] as int?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      originalUrl: map['originalUrl'] as String? ?? '',
      normalizedUrl: map['normalizedUrl'] as String? ?? '',
      platform: map['platform'] as String? ?? 'unknown',
      backendUrl: map['backendUrl'] as String? ?? '',
      errorMessage:
          error['message'] as String? ?? map['errorMessage'] as String? ?? '',
      stackTrace:
          error['stackTrace'] as String? ?? map['stackTrace'] as String? ?? '',
      appVersion: app['version'] as String? ?? '1.0.0+1',
      device: device,
    );
  }
}
