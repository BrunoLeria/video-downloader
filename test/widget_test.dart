import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/main.dart';
import 'package:video_downloader/providers/app_provider.dart';

void main() {
  testWidgets('renderiza a tela de termos quando o aviso ainda não foi aceito', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MaterialApp(home: VideoDownloaderApp()),
      ),
    );

    expect(find.text('Aviso de uso'), findsOneWidget);
  });
}
