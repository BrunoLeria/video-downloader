import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static DateTime? _lastProgressUpdate;
  static int? _lastProgress;

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: initSettings);
  }

  static Future<void> showProgressNotification({
    required String title,
    required int progress,
  }) async {
    final now = DateTime.now();
    final shouldUpdate = progress >= 100 ||
        _lastProgressUpdate == null ||
        now.difference(_lastProgressUpdate!) >= const Duration(milliseconds: 500);
    if (!shouldUpdate && progress != _lastProgress) {
      return;
    }

    _lastProgressUpdate = now;
    _lastProgress = progress;
    final androidDetails = AndroidNotificationDetails(
      'video_downloader_channel',
      'Downloads',
      channelDescription: 'Notificações de progresso de download',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
    );

    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: 100,
      title: title,
      body: 'Download em andamento',
      notificationDetails: details,
      payload: 'download',
    );
  }

  static Future<void> cancelNotifications() async {
    _lastProgressUpdate = null;
    _lastProgress = null;
    await _plugin.cancelAll();
  }

  static Future<void> showBasicNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'video_downloader_channel',
      'Downloads',
      channelDescription: 'Avisos de download',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      id: 101,
      title: title,
      body: body,
      notificationDetails: details,
      payload: 'status',
    );
  }
}
