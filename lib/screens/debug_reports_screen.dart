import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/providers/app_provider.dart';

class DebugReportsScreen extends StatelessWidget {
  const DebugReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final reports = app.debugReports;

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios de diagnóstico')),
      body: reports.isEmpty
          ? const Center(child: Text('Nenhum relatório de erro registrado.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final device = report.device;
                return Card(
                  child: ExpansionTile(
                    title: Text(report.originalUrl),
                    subtitle: Text(
                      '${report.platform} • ${report.createdAt.toLocal()}',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              report.errorMessage,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dispositivo: ${device['manufacturer'] ?? ''} '
                              '${device['model'] ?? device['name'] ?? ''}',
                            ),
                            Text('Backend: ${report.backendUrl}'),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => app.shareDebugReport(report),
                              icon: const Icon(Icons.share),
                              label: const Text('Exportar/compartilhar JSON'),
                            ),
                            const SizedBox(height: 8),
                            FilledButton.icon(
                              onPressed: () async {
                                final opened = await app.openDebugReportIssue(
                                  report,
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      opened
                                          ? 'Abrindo issue no GitHub.'
                                          : 'Não foi possível abrir o GitHub.',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.bug_report),
                              label: const Text('Enviar ao GitHub'),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                if (report.id != null) {
                                  app.deleteDebugReport(report.id!);
                                }
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Excluir relatório'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
