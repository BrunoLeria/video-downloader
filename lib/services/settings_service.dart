import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_downloader/models/app_settings.dart';

class SettingsService {
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    var backendUrl = prefs.getString('backendUrl') ?? 'http://127.0.0.1:8000';
    if (backendUrl.contains('example.com') ||
        backendUrl.contains('192.168.15.10') ||
        backendUrl.trim().isEmpty) {
      backendUrl = 'http://127.0.0.1:8000';
      await prefs.setString('backendUrl', backendUrl);
    }
    return AppSettings(
      acceptedTerms: prefs.getBool('acceptedTerms') ?? false,
      themeMode: prefs.getString('themeMode') ?? 'system',
      defaultQuality: prefs.getString('defaultQuality') ?? '720p',
      downloadDirectory: prefs.getString('downloadDirectory') ?? '',
      maxConcurrentDownloads: prefs.getInt('maxConcurrentDownloads') ?? 2,
      downloadOnlyOnWifi: prefs.getBool('downloadOnlyOnWifi') ?? false,
      autoDeleteQuickShare: prefs.getBool('autoDeleteQuickShare') ?? false,
      backendUrl: backendUrl,
      lastUrl: prefs.getString('lastUrl') ?? '',
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('acceptedTerms', settings.acceptedTerms);
    await prefs.setString('themeMode', settings.themeMode);
    await prefs.setString('defaultQuality', settings.defaultQuality);
    await prefs.setString('downloadDirectory', settings.downloadDirectory);
    await prefs.setInt(
      'maxConcurrentDownloads',
      settings.maxConcurrentDownloads,
    );
    await prefs.setBool('downloadOnlyOnWifi', settings.downloadOnlyOnWifi);
    await prefs.setBool('autoDeleteQuickShare', settings.autoDeleteQuickShare);
    await prefs.setString('backendUrl', settings.backendUrl);
    await prefs.setString('lastUrl', settings.lastUrl);
  }
}
