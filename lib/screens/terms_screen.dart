import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/providers/app_provider.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppProvider>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Aviso de uso',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                'Use este aplicativo apenas para conteúdo de sua autoria, de domínio público, com licença que permita download ou com autorização explícita do titular dos direitos. Você é responsável pelo uso de qualquer arquivo baixado. Não utilize o app para burlar DRM, acessos privados, conteúdos protegidos ou qualquer medida técnica de proteção.',
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  app.acceptTerms();
                },
                icon: const Icon(Icons.check),
                label: const Text('Aceito e quero continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
