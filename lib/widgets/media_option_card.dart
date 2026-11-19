import 'package:flutter/material.dart';
import 'package:video_downloader/models/media_option.dart';

class MediaOptionCard extends StatelessWidget {
  const MediaOptionCard({super.key, required this.option, required this.onTap});

  final MediaOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          option.type == MediaType.audio ? Icons.audiotrack : Icons.videocam,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text('${option.quality} • ${option.format.toUpperCase()}'),
        subtitle: Text(option.sizeLabel ?? 'Tamanho estimado indisponível'),
        trailing: FilledButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.download),
          label: const Text('Baixar'),
        ),
      ),
    );
  }
}
