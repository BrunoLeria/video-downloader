import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/models/media_info.dart';
import 'package:video_downloader/models/media_option.dart';
import 'package:video_downloader/providers/app_provider.dart';
import 'package:video_downloader/widgets/media_option_card.dart';
import 'package:video_downloader/widgets/platform_badge.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.media, required this.options});

  final MediaInfo media;
  final List<MediaOption> options;

  Future<void> _startDownload(
    BuildContext context,
    AppProvider app,
    MediaInfo media,
    MediaOption option,
  ) async {
    final started = await app.downloadMedia(media, option);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          started
              ? 'Download concluído. Consulte a tela Downloads.'
              : app.debugErrorDetails ?? app.errorMessage ?? 'Não foi possível iniciar o download.',
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Pré-visualização')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (media.thumbnail.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    media.thumbnail,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  PlatformBadge(platform: media.platform),
                  const Spacer(),
                  Text('${media.duration.inMinutes} min'),
                ],
              ),
              const SizedBox(height: 12),
              Text(media.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(media.author, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              Text('Opções disponíveis', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MediaOptionCard(
                    option: option,
                    onTap: () => _startDownload(context, app, media, option),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: options.isEmpty ? null : () => _startDownload(context, app, media, options.first),
                icon: const Icon(Icons.download),
                label: const Text('Baixar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
