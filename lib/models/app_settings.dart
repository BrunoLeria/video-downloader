import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.acceptedTerms = false,
    this.themeMode = 'system',
    this.defaultQuality = '720p',
    this.downloadDirectory = '',
    this.maxConcurrentDownloads = 2,
    this.downloadOnlyOnWifi = false,
    this.autoDeleteQuickShare = false,
    this.backendUrl = 'http://127.0.0.1:8000',
    this.lastUrl = '',
  });

  final bool acceptedTerms;
  final String themeMode;
  final String defaultQuality;
  final String downloadDirectory;
  final int maxConcurrentDownloads;
  final bool downloadOnlyOnWifi;
  final bool autoDeleteQuickShare;
  final String backendUrl;
  final String lastUrl;

  ThemeMode get resolvedThemeMode {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  AppSettings copyWith({
    bool? acceptedTerms,
    String? themeMode,
    String? defaultQuality,
    String? downloadDirectory,
    int? maxConcurrentDownloads,
    bool? downloadOnlyOnWifi,
    bool? autoDeleteQuickShare,
    String? backendUrl,
    String? lastUrl,
  }) {
    return AppSettings(
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      themeMode: themeMode ?? this.themeMode,
      defaultQuality: defaultQuality ?? this.defaultQuality,
      downloadDirectory: downloadDirectory ?? this.downloadDirectory,
      maxConcurrentDownloads:
          maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      downloadOnlyOnWifi: downloadOnlyOnWifi ?? this.downloadOnlyOnWifi,
      autoDeleteQuickShare: autoDeleteQuickShare ?? this.autoDeleteQuickShare,
      backendUrl: backendUrl ?? this.backendUrl,
      lastUrl: lastUrl ?? this.lastUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'acceptedTerms': acceptedTerms,
    'themeMode': themeMode,
    'defaultQuality': defaultQuality,
    'downloadDirectory': downloadDirectory,
    'maxConcurrentDownloads': maxConcurrentDownloads,
    'downloadOnlyOnWifi': downloadOnlyOnWifi,
    'autoDeleteQuickShare': autoDeleteQuickShare,
    'backendUrl': backendUrl,
    'lastUrl': lastUrl,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      acceptedTerms: json['acceptedTerms'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'system',
      defaultQuality: json['defaultQuality'] as String? ?? '720p',
      downloadDirectory: json['downloadDirectory'] as String? ?? '',
      maxConcurrentDownloads:
          (json['maxConcurrentDownloads'] as num?)?.toInt() ?? 2,
      downloadOnlyOnWifi: json['downloadOnlyOnWifi'] as bool? ?? false,
      autoDeleteQuickShare: json['autoDeleteQuickShare'] as bool? ?? false,
      backendUrl: json['backendUrl'] as String? ?? 'http://127.0.0.1:8000',
      lastUrl: json['lastUrl'] as String? ?? '',
    );
  }
}
