import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_downloader/providers/app_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: app.history.isEmpty
          ? const Center(child: Text('Nenhum download salvo ainda.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: app.history.length,
              itemBuilder: (context, index) {
                final item = app.history[index];
                return Card(
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text('${item.platform} • ${item.savedAt.toLocal()}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'open') {
                          OpenFilex.open(item.filePath);
                        }
                        if (value == 'share') {
                          SharePlus.instance.share(
                            ShareParams(files: [XFile(item.filePath)]),
                          );
                        }
                        if (value == 'delete') {
                          app.deleteHistoryItem(item.id ?? -1);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'open', child: Text('Abrir')),
                        PopupMenuItem(value: 'share', child: Text('Compartilhar')),
                        PopupMenuItem(value: 'delete', child: Text('Excluir')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
