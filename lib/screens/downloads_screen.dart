import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/providers/app_provider.dart';
import 'package:video_downloader/widgets/download_tile.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: app.downloads.isEmpty
          ? const Center(child: Text('Nenhum download em andamento.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: app.downloads.length,
              itemBuilder: (context, index) {
                final task = app.downloads[index];
                return DownloadTile(
                  task: task,
                  onCancel: () => app.cancelDownload(task.id),
                  onOpen: () async {
                    final filePath = task.filePath;
                    if (filePath == null || filePath.isEmpty) {
                      return;
                    }
                    final result = await OpenFilex.open(filePath);
                    if (!context.mounted || result.type == ResultType.done) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Não foi possível abrir o arquivo: ${result.message}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
