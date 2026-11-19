import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/models/app_settings.dart';
import 'package:video_downloader/providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _backendController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppProvider>().settings;
    _backendController.text = settings.backendUrl;
  }

  @override
  void dispose() {
    _backendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final settings = app.settings;
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: settings.themeMode,
            items: const [
              DropdownMenuItem(value: 'system', child: Text('Sistema')),
              DropdownMenuItem(value: 'light', child: Text('Claro')),
              DropdownMenuItem(value: 'dark', child: Text('Escuro')),
            ],
            onChanged: (value) {
              if (value == null) return;
              app.saveSettings(settings.copyWith(themeMode: value));
            },
            decoration: const InputDecoration(labelText: 'Tema'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: settings.defaultQuality,
            decoration: const InputDecoration(labelText: 'Qualidade padrão'),
            onChanged: (value) =>
                app.saveSettings(settings.copyWith(defaultQuality: value)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: settings.maxConcurrentDownloads.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Máximo de downloads simultâneos',
            ),
            onChanged: (value) {
              final number = int.tryParse(value) ?? 2;
              app.saveSettings(
                settings.copyWith(maxConcurrentDownloads: number),
              );
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: settings.downloadOnlyOnWifi,
            onChanged: (value) =>
                app.saveSettings(settings.copyWith(downloadOnlyOnWifi: value)),
            title: const Text('Baixar apenas no Wi‑Fi'),
          ),
          SwitchListTile(
            value: settings.autoDeleteQuickShare,
            onChanged: (value) => app.saveSettings(
              settings.copyWith(autoDeleteQuickShare: value),
            ),
            title: const Text('Excluir após compartilhar no download rápido'),
            subtitle: const Text(
              'O arquivo temporário será removido quando o compartilhamento terminar.',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _backendController,
            decoration: const InputDecoration(
              labelText: 'URL do backend de extração',
            ),
            onFieldSubmitted: (value) =>
                app.saveSettings(settings.copyWith(backendUrl: value)),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () {
              app.saveSettings(
                settings.copyWith(backendUrl: _backendController.text.trim()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuração salva.')),
              );
            },
            child: const Text('Salvar configurações'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () {
              app.saveSettings(const AppSettings(acceptedTerms: true));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Aviso revisado.')));
            },
            child: const Text('Rever aviso de uso'),
          ),
        ],
      ),
    );
  }
}
