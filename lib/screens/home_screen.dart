import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:video_downloader/providers/app_provider.dart';
import 'package:video_downloader/screens/downloads_screen.dart';
import 'package:video_downloader/screens/history_screen.dart';
import 'package:video_downloader/screens/settings_screen.dart';
import 'package:video_downloader/screens/preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  StreamSubscription? _shareSubscription;
  late final AppProvider _appProvider;

  @override
  void initState() {
    super.initState();
    _appProvider = context.read<AppProvider>();
    _shareSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((
      media,
    ) {
      final sharedText = media
          .where(
            (item) =>
                item.type == SharedMediaType.url ||
                item.type == SharedMediaType.text,
          )
          .map((item) => item.path)
          .firstWhere((value) => value.trim().isNotEmpty, orElse: () => '');
      if (sharedText.isEmpty) {
        return;
      }
      _handleSharedLink(sharedText);
    });
    ReceiveSharingIntent.instance.getInitialMedia().then((media) {
      final sharedText = media
          .where(
            (item) =>
                item.type == SharedMediaType.url ||
                item.type == SharedMediaType.text,
          )
          .map((item) => item.path)
          .firstWhere((value) => value.trim().isNotEmpty, orElse: () => '');
      if (sharedText.isNotEmpty) {
        _handleSharedLink(sharedText);
      }
    });
  }

  Future<void> _handleSharedLink(String sharedText) async {
    if (!mounted) {
      return;
    }

    final extractedUrl = _extractUrl(sharedText);
    if (extractedUrl == null) {
      _controller.text = sharedText;
      return;
    }

    _controller.text = extractedUrl;
    await _appProvider.fetchMedia(extractedUrl);
    if (!mounted) {
      return;
    }

    final url = Uri.tryParse(extractedUrl);
    final host = url?.host.toLowerCase() ?? '';
    final isSupportedShare =
        host.contains('instagram.com') ||
        host.contains('youtube.com') ||
        host.contains('youtu.be');
    if (isSupportedShare) {
      await _appProvider.quickDownload();
    }
  }

  String? _extractUrl(String text) {
    final match = RegExp(
      r'https?:\/\/[^\s]+',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(0)?.replaceAll(RegExp(r'[)\]},.;]+$'), '');
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    void openPreview() {
      final media = app.currentMedia;
      if (media == null) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              PreviewScreen(media: media, options: app.currentOptions),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloader'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const DownloadsScreen())),
            icon: const Icon(Icons.download),
          ),
          IconButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'Cole o link',
                  hintText: 'https://www.youtube.com/watch?v=...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () async {
                      final text = await Clipboard.getData(
                        Clipboard.kTextPlain,
                      );
                      final value = text?.text ?? '';
                      if (value.isNotEmpty) {
                        _controller.text = value;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: app.isLoading
                    ? null
                    : () => app.fetchMedia(_controller.text),
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
              const SizedBox(height: 16),
              if (app.isLoading) const LinearProgressIndicator(),
              if (app.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.errorMessage!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (!kReleaseMode && app.debugErrorDetails != null) ...[
                        const SizedBox(height: 8),
                        SelectableText(
                          app.debugErrorDetails!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontFamily: 'monospace',
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (app.currentMedia != null)
                Card(
                  margin: const EdgeInsets.only(top: 16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: openPreview,
                    child: ListTile(
                      leading: app.currentMedia!.thumbnail.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                app.currentMedia!.thumbnail,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.play_circle_fill, size: 40),
                      title: Text(app.currentMedia!.title),
                      subtitle: Text(
                        '${app.currentMedia!.author} • ${app.currentMedia!.duration.inMinutes} min',
                      ),
                      trailing: const Icon(Icons.open_in_new),
                    ),
                  ),
                ),
              if (app.currentMedia != null && app.quickDownloadOption != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: FilledButton.icon(
                    onPressed: app.isLoading
                        ? null
                        : () async {
                            final started = await app.quickDownload();
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  started
                                      ? 'Download rápido iniciado na melhor qualidade disponível.'
                                      : app.debugErrorDetails ??
                                            app.errorMessage ??
                                            'Não foi possível iniciar o download.',
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Compartilhamento rápido (MP4)'),
                  ),
                ),
              if (app.currentMedia == null && !app.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Nenhuma mídia encontrada. Cole um link e pressione Buscar.',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
