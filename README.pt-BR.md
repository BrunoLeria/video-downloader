# Video Downloader

**Idiomas:** [English](README.md) | [Português (Brasil)](README.pt-BR.md)

Aplicativo Flutter para localizar mídia para download a partir de links
suportados e compartilhá-la rapidamente no Android ou iOS. Os vídeos do YouTube
são processados localmente, enquanto outras solicitações de extração são
enviadas para um backend Python configurável.

## Funcionalidades

- Extração de vídeo e áudio do YouTube
- Reels e publicações do Instagram pelo backend de extração
- Detecção de plataforma e normalização de URLs
- Seleção da qualidade do download
- Download rápido de MP4 e compartilhamento
- Exclusão opcional do arquivo temporário após o compartilhamento rápido
- Histórico de downloads e notificações
- Suporte para Android e iOS

## Requisitos

- Flutter SDK 3.13 ou mais recente
- Dart SDK 3.13 ou mais recente
- Python 3.10 ou mais recente
- Android Studio e Android SDK para builds Android
- Xcode para builds iOS

## Instalar dependências

```powershell
flutter pub get
python -m pip install yt-dlp
```

## Executar o backend de extração

Execute o backend a partir da raiz do projeto:

```powershell
python backend\example_backend.py
```

O servidor usa a porta `8000` e aceita requisições `POST` com este formato:

```json
{
  "url": "https://www.instagram.com/reel/ABC123/",
  "mode": "info",
  "platform": "instagram"
}
```

Use `"mode": "options"` para retornar as opções de mídia disponíveis.

Para testes locais no Android, configure o aplicativo para usar o redirecionamento
ADB:

```powershell
adb reverse tcp:8000 tcp:8000
```

Depois, configure no aplicativo a URL do backend:

```text
http://127.0.0.1:8000
```

Isso permite que o celular alcance o backend executado no PC por USB. O
redirecionamento não é necessário quando o backend estiver hospedado publicamente.

## Executar o aplicativo

Conecte um dispositivo ou inicialize um emulador:

```powershell
flutter devices
flutter run -d RQCY701ZPZZ
```

Para compilar e instalar um APK Android de release:

```powershell
flutter build apk --release
flutter install -d RQCY701ZPZZ
```

O APK é gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Testes

Execute a análise estática e todos os testes:

```powershell
flutter analyze
flutter test
```

## Relatórios de diagnóstico

Falhas de extração são armazenadas localmente e podem ser abertas em
**Configurações > Relatórios de diagnóstico**.

Cada relatório pode ser compartilhado como JSON ou aberto como uma issue
preenchida no GitHub. Os relatórios exportados incluem os URLs original e
normalizado, plataforma, URL do backend, erro, stack trace, versão do aplicativo
e modelo do dispositivo.

Reexecute um relatório exportado a partir da raiz do projeto:

```powershell
python backend\debug_report_replay.py debug-report.json
```

## Compartilhamento rápido temporário

A ação **Compartilhamento rápido (MP4)** baixa a melhor opção MP4 disponível e
abre a tela de compartilhamento da plataforma. Ative **Excluir após compartilhar
no download rápido** nas Configurações para excluir o arquivo temporário após o
compartilhamento.

Arquivos que não forem configurados para exclusão temporária permanecem na pasta
Downloads e são registrados no Histórico.

## Segurança do backend e uso responsável

- Implante o backend apenas em infraestrutura sob seu controle.
- Adicione autenticação, limite de requisições, lista de URLs permitidas e HTTPS antes de uma implantação pública.
- Restrinja as requisições às plataformas e tipos de conteúdo suportados pelo aplicativo.
- Mantenha o `yt-dlp` fixado em uma versão e revise atualizações antes do uso.
- Baixe e compartilhe apenas mídia que você tenha autorização para utilizar ou distribuir.
