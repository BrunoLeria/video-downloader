import 'package:flutter/material.dart';
import 'package:video_downloader/models/download_task.dart';
import 'package:video_downloader/services/download_service.dart';

class DownloadTile extends StatelessWidget {
  const DownloadTile({
    super.key,
    required this.task,
    required this.onCancel,
    required this.onOpen,
  });

  final DownloadTask task;
  final VoidCallback onCancel;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final percent = (task.progress * 100).round();
    final remaining = task.totalBytes > 0
        ? ((task.totalBytes - task.bytesReceived) /
              (task.bytesReceived > 0 ? task.bytesReceived : 1))
        : 0.0;
    final remainingSeconds = (remaining * 60).round();
    final remainingLabel = DownloadService.formatRemaining(
      Duration(seconds: remainingSeconds),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: task.filePath == null ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (task.status == 'downloading')
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancelar'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${task.optionLabel} • ${task.platform}'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: task.progress.clamp(0.0, 1.0)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$percent%'),
                  Text(
                    '${DownloadService.formatSize(task.bytesReceived)} / ${DownloadService.formatSize(task.totalBytes)}',
                  ),
                  Text(remainingLabel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
