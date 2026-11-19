import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/providers/app_provider.dart';
import 'package:video_downloader/screens/home_screen.dart';
import 'package:video_downloader/screens/terms_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VideoDownloaderApp());
}

class VideoDownloaderApp extends StatefulWidget {
  const VideoDownloaderApp({super.key});

  @override
  State<VideoDownloaderApp> createState() => _VideoDownloaderAppState();
}

class _VideoDownloaderAppState extends State<VideoDownloaderApp> {
  late final AppProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AppProvider();
    _provider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<AppProvider>(
        builder: (context, app, child) {
          final themeMode = switch (app.settings.themeMode) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          };

          return MaterialApp(
            title: 'Video Downloader',
            themeMode: themeMode,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            home: app.needsTerms ? const TermsScreen() : const HomeScreen(),
          );
        },
      ),
    );
  }
}
