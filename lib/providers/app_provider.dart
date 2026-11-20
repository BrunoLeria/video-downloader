import 'dart:io';

import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_downloader/extractors/generic_extractor.dart';
import 'package:video_downloader/extractors/instagram_extractor.dart';
import 'package:video_downloader/extractors/media_extractor.dart';
import 'package:video_downloader/extractors/youtube_extractor.dart';
import 'package:video_downloader/models/app_settings.dart';
import 'package:video_downloader/models/download_history.dart';
import 'package:video_downloader/models/download_task.dart';
import 'package:video_downloader/models/debug_report.dart';
import 'package:video_downloader/models/media_info.dart';
import 'package:video_downloader/models/media_option.dart';
import 'package:video_downloader/services/app_database.dart';
import 'package:video_downloader/services/download_service.dart';
import 'package:video_downloader/services/notification_service.dart';
import 'package:video_downloader/services/permission_service.dart';
import 'package:video_downloader/services/platform_detector.dart';
import 'package:video_downloader/services/settings_service.dart';
import 'package:video_downloader/services/url_normalizer.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _settingsService = SettingsService();
  }

  late final SettingsService _settingsService;
  final AppDatabase _database = AppDatabase.instance;
  final List<MediaExtractor> _extractors = [];

  AppSettings _settings = const AppSettings();
  bool _isLoading = false;
  bool _needsTerms = true;
  String? _errorMessage;
  String? _debugErrorDetails;
  MediaInfo? _currentMedia;
  List<MediaOption> _currentOptions = const [];
  List<DownloadTask> _downloads = const [];
  List<DownloadHistoryItem> _history = const [];
  List<DebugReport> _debugReports = const [];

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get needsTerms => _needsTerms;
  String? get errorMessage => _errorMessage;
  String? get debugErrorDetails => _debugErrorDetails;
  MediaInfo? get currentMedia => _currentMedia;
  List<MediaOption> get currentOptions => _currentOptions;
  List<DownloadTask> get downloads => _downloads;
  List<DownloadHistoryItem> get history => _history;
  List<DebugReport> get debugReports => _debugReports;

  MediaOption? get quickDownloadOption {
    if (_currentOptions.isEmpty) {
      return null;
    }

    final candidates = _currentOptions.where(
      (option) =>
          option.type != MediaType.audio && option.url.trim().isNotEmpty,
    );
    if (candidates.isEmpty) {
      final audio = _currentOptions.where(
        (option) => option.url.trim().isNotEmpty,
      );
      return audio.isEmpty ? null : audio.first;
    }

    int score(MediaOption option) {
      final quality =
          int.tryParse(
            RegExp(r'(\d{3,4})p')
                    .firstMatch(option.quality.toLowerCase())
                    ?.group(1) ??
                '',
          ) ??
          0;
      final format = option.format.toLowerCase();
      final mp4Score = format == 'mp4' ? 1000000 : 0;
      return mp4Score +
          quality * 1000 +
          (option.estimatedBytes ?? 0).clamp(0, 999);
    }

    return candidates.reduce(
      (best, option) => score(option) > score(best) ? option : best,
    );
  }

  Future<void> initialize() async {
    _settings = await _settingsService.load();
    _needsTerms = !_settings.acceptedTerms;
    _extractors.addAll([
      YoutubeExtractor(),
      InstagramExtractor(backendUrl: _settings.backendUrl),
      GenericExtractor(backendUrl: _settings.backendUrl),
    ]);
    await _database.initialize();
    _history = await _database.fetchDownloads();
    _debugReports = await _database.fetchDebugReports();
    await NotificationService.initialize();
    notifyListeners();
  }

  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
    await _settingsService.save(settings);
    _extractors.clear();
    _extractors.addAll([
      YoutubeExtractor(),
      InstagramExtractor(backendUrl: settings.backendUrl),
      GenericExtractor(backendUrl: settings.backendUrl),
    ]);
    notifyListeners();
  }

  void acceptTerms() {
    _needsTerms = false;
    final updated = _settings.copyWith(acceptedTerms: true);
    saveSettings(updated);
  }

  MediaExtractor? _resolveExtractor(Uri url) {
    for (final extractor in _extractors) {
      if (extractor.canHandle(url)) {
        return extractor;
      }
    }
    return null;
  }

  Future<void> fetchMedia(String rawUrl) async {
    _errorMessage = null;
    _debugErrorDetails = null;
    if (rawUrl.trim().isEmpty) {
      _errorMessage = 'Cole um link antes de buscar.';
      notifyListeners();
      return;
    }

    try {
      final normalized = UrlNormalizer.normalize(rawUrl);
      final uri = Uri.parse(normalized);
      final detector = PlatformDetector.detect(normalized);
      if (detector == SupportedPlatform.unsupported) {
        _errorMessage = 'Plataforma não suportada.';
        notifyListeners();
        return;
      }

      final extractor = _resolveExtractor(uri);
      if (extractor == null) {
        _errorMessage = 'Não foi possível reconhecer o link. Tente outro URL.';
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      final info = await extractor.fetchInfo(uri);
      final options = await extractor.listOptions(info);
      if (options.isEmpty) {
        await _recordDebugReport(
          originalUrl: rawUrl,
          normalizedUrl: normalized,
          platform: detector.name,
          errorMessage: 'Mídia indisponível ou privada.',
          stackTrace: '',
        );
        _errorMessage = 'Mídia indisponível ou privada.';
        _currentMedia = null;
        _currentOptions = const [];
        notifyListeners();
        return;
      }

      _currentMedia = info;
      _currentOptions = options;
      _settings = _settings.copyWith(lastUrl: normalized);
      await _settingsService.save(_settings);
      _errorMessage = null;
    } catch (error, stackTrace) {
      final message = error.toString();
      _debugErrorDetails = kDebugMode ? '$message\n$stackTrace' : null;
      debugPrint('Erro ao buscar mídia: $message');
      debugPrintStack(stackTrace: stackTrace);
      await _recordDebugReport(
        originalUrl: rawUrl,
        normalizedUrl: (() {
          try {
            return UrlNormalizer.normalize(rawUrl);
          } catch (_) {
            return rawUrl.trim();
          }
        })(),
        platform: PlatformDetector.detect(rawUrl).name,
        errorMessage: message,
        stackTrace: stackTrace.toString(),
      );
      _errorMessage = 'Não foi possível carregar a mídia. Verifique o link e tente novamente.';
      _currentMedia = null;
      _currentOptions = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> downloadMedia(
    MediaInfo info,
    MediaOption option, {
    bool quickShare = false,
  }) async {
    final safeName = _safeName(
      '${info.title}_${option.quality}_${option.format}',
    );
    final task = DownloadTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: info.title,
      platform: info.platform.name,
      optionLabel: option.label,
      fileName: safeName,
      status: 'downloading',
      progress: 0,
      cancelToken: CancelToken(),
    );

    final downloads = [..._downloads];
    downloads.insert(0, task);
    _downloads = downloads;
    notifyListeners();

    try {
      if (option.url.trim().isEmpty) {
        throw const FormatException(
          'A opção selecionada não possui URL de download.',
        );
      }

      final hasPermission =
          await PermissionService.requestDownloadPermissions();
      if (!hasPermission) {
        throw const FileSystemException('Permissão de armazenamento negada.');
      }

      final directory = await PermissionService.ensureDirectory(
        _settings.downloadDirectory,
      );
      final savePath = '${directory.path}/$safeName';
      await NotificationService.showProgressNotification(
        title: info.title,
        progress: 0,
      );
      final filePath = await DownloadService.downloadFile(
        url: option.url,
        savePath: savePath,
        cancelToken: task.cancelToken,
        onProgress: (received, total) {
          final progress = total > 0 ? (received / total) : 0.0;
          final updated = task.copyWith(
            progress: progress,
            bytesReceived: received,
            totalBytes: total,
            status: 'downloading',
          );
          final list = [..._downloads];
          final index = list.indexWhere((item) => item.id == task.id);
          if (index >= 0) {
            list[index] = updated;
            _downloads = list;
            notifyListeners();
          }
          NotificationService.showProgressNotification(
            title: info.title,
            progress: (progress * 100).round(),
          );
        },
      );

      final completion = task.copyWith(
        status: 'completed',
        progress: 1,
        filePath: filePath,
      );
      final list = [..._downloads];
      final index = list.indexWhere((item) => item.id == task.id);
      if (index >= 0) {
        list[index] = completion;
        _downloads = list;
      }

      final file = File(filePath);
      final stat = await file.stat();
      if (!quickShare || !_settings.autoDeleteQuickShare) {
        final entry = DownloadHistoryItem(
          id: null,
          title: info.title,
          platform: info.platform.name,
          savedAt: DateTime.now(),
          fileSizeBytes: stat.size,
          status: 'completed',
          filePath: filePath,
          url: option.url,
        );
        await _database.insertDownload(entry);
        _history = await _database.fetchDownloads();
      }
      await NotificationService.showBasicNotification(
        title: 'Download finalizado',
        body: 'Arquivo salvo em ${directory.path}',
      );
      if (quickShare) {
        await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));
        if (_settings.autoDeleteQuickShare) {
          await File(filePath).delete();
          if (index >= 0) {
            list[index] = completion.copyWith(filePath: '');
            _downloads = list;
          }
        }
      } else {
        await OpenFilex.open(filePath);
      }
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      final message = error.toString();
      _debugErrorDetails = kDebugMode ? '$message\n$stackTrace' : null;
      debugPrint('Erro no download: $message');
      debugPrintStack(stackTrace: stackTrace);
      final list = [..._downloads];
      final index = list.indexWhere((item) => item.id == task.id);
      if (index >= 0) {
        list[index] = list[index].copyWith(
          status: 'failed',
          errorMessage: message,
        );
        _downloads = list;
      }
      _errorMessage = 'Não foi possível concluir o download.';
      try {
        await NotificationService.showBasicNotification(
          title: 'Download falhou',
          body: 'Verifique sua conexão e o espaço disponível.',
        );
      } catch (notificationError, notificationStackTrace) {
        debugPrint('Erro ao mostrar notificação de falha: $notificationError');
        debugPrintStack(stackTrace: notificationStackTrace);
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> quickDownload() async {
    final media = _currentMedia;
    final option = quickDownloadOption;
    if (media == null || option == null) {
      _errorMessage = 'Nenhuma opção de download está disponível.';
      notifyListeners();
      return false;
    }
    return downloadMedia(media, option, quickShare: true);
  }

  Future<void> cancelDownload(String taskId) async {
    final list = [..._downloads];
    final task = list.firstWhere(
      (item) => item.id == taskId,
      orElse: () => DownloadTask(
        id: '',
        title: '',
        platform: '',
        optionLabel: '',
        fileName: '',
      ),
    );
    if (task.id.isEmpty) {
      return;
    }
    task.cancelToken?.cancel();
    final updated = task.copyWith(status: 'cancelled');
    final index = list.indexWhere((item) => item.id == taskId);
    list[index] = updated;
    _downloads = list;
    notifyListeners();
  }

  Future<void> refreshHistory() async {
    _history = await _database.fetchDownloads();
    notifyListeners();
  }

  Future<void> deleteHistoryItem(int id) async {
    await _database.deleteDownload(id);
    _history = await _database.fetchDownloads();
    notifyListeners();
  }

  Future<void> refreshDebugReports() async {
    _debugReports = await _database.fetchDebugReports();
    notifyListeners();
  }

  Future<void> deleteDebugReport(int id) async {
    await _database.deleteDebugReport(id);
    _debugReports = await _database.fetchDebugReports();
    notifyListeners();
  }

  Future<void> shareDebugReport(DebugReport report) async {
    await SharePlus.instance.share(
      ShareParams(
        text: report.toPrettyJson(),
        subject: 'Video Downloader debug report',
      ),
    );
  }

  Future<bool> openDebugReportIssue(DebugReport report) async {
    final body = report.toPrettyJson();
    final uri = Uri.https(
      'github.com',
      '/BrunoLeria/video-downloader/issues/new',
      {
        'title':
            'Instagram extraction failed: ${report.originalUrl.length > 80 ? '${report.originalUrl.substring(0, 80)}...' : report.originalUrl}',
        'body': '```json\n$body\n```',
        'labels': 'bug,debug-report',
      },
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _recordDebugReport({
    required String originalUrl,
    required String normalizedUrl,
    required String platform,
    required String errorMessage,
    required String stackTrace,
  }) async {
    final device = await _readDeviceDetails();
    final report = DebugReport(
      id: null,
      createdAt: DateTime.now(),
      originalUrl: originalUrl,
      normalizedUrl: normalizedUrl,
      platform: platform,
      backendUrl: _settings.backendUrl,
      errorMessage: errorMessage,
      stackTrace: stackTrace,
      appVersion: '1.0.0+1',
      device: device,
    );
    await _database.insertDebugReport(report);
    _debugReports = await _database.fetchDebugReports();
  }

  Future<Map<String, dynamic>> _readDeviceDetails() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return {
        'platform': 'android',
        'manufacturer': info.manufacturer,
        'model': info.model,
        'androidVersion': info.version.release,
        'sdkInt': info.version.sdkInt,
        'device': info.device,
      };
    }
    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return {
        'platform': 'ios',
        'model': info.model,
        'name': info.name,
        'systemName': info.systemName,
        'systemVersion': info.systemVersion,
      };
    }
    return {'platform': Platform.operatingSystem};
  }

  String _safeName(String input) {
    final safe = input
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return '${safe.isEmpty ? 'download' : safe}.mp4';
  }
}
