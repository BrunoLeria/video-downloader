# Video Downloader

**Languages:** [English](README.md) | [Português (Brasil)](README.pt-BR.md)

Flutter app for discovering downloadable media from supported links and sharing
it quickly from Android or iOS. YouTube videos are handled locally, while other
supported extraction requests are sent to a configurable Python backend.

## Features

- YouTube video and audio extraction
- Instagram Reels and posts through the extraction backend
- Platform detection and URL normalization
- Download quality selection
- Quick MP4 download and share flow
- Optional temporary-file deletion after quick sharing
- Download history and notifications
- Android and iOS support

## Requirements

- Flutter SDK 3.13 or newer
- Dart SDK 3.13 or newer
- Python 3.10 or newer
- Android Studio and an Android SDK for Android builds
- Xcode for iOS builds

## Install dependencies

```powershell
flutter pub get
python -m pip install yt-dlp
```

## Run the extraction backend

Start the backend from the project root:

```powershell
python backend\example_backend.py
```

The server listens on port `8000`. The backend accepts `POST` requests with:

```json
{
  "url": "https://www.instagram.com/reel/ABC123/",
  "mode": "info",
  "platform": "instagram"
}
```

Use `"mode": "options"` to return available media URLs.

For local Android testing, configure the app to use an ADB reverse tunnel:

```powershell
adb reverse tcp:8000 tcp:8000
```

Then set the backend URL in the app to:

```text
http://127.0.0.1:8000
```

This makes the phone reach the backend on the PC through USB. It is not required
for a hosted production backend.

## Run the app

Connect a device or start an emulator, then run:

```powershell
flutter devices
flutter run -d RQCY701ZPZZ
```

To build and install an Android release APK:

```powershell
flutter build apk --release
flutter install -d RQCY701ZPZZ
```

The APK is generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Test

Run static analysis and the full test suite:

```powershell
flutter analyze
flutter test
```

## Debug reports

Extraction failures are stored locally and can be opened from
**Settings > Relatórios de diagnóstico**.

Each report can be shared as JSON or opened as a prefilled GitHub issue. Exported
reports include the original and normalized URLs, platform, backend URL, error,
stack trace, app version, and device model.

Replay an exported report from the project root:

```powershell
python backend\debug_report_replay.py debug-report.json
```

## Temporary quick sharing

The **Compartilhamento rápido (MP4)** action downloads the best available MP4 and
opens the platform share sheet. Enable **Excluir após compartilhar no download
rápido** in Settings to delete the temporary file after sharing.

Files that are not configured for temporary deletion remain in the Downloads
directory and are recorded in History.

## Android share shortcut

Instagram links and YouTube Shorts can be shared directly from the Android share
menu. The app recognizes the shared URL, extracts the media, and opens the
quick-share sheet automatically.

## Backend security and responsible use

- Deploy the backend only on infrastructure you control.
- Add authentication, rate limiting, URL allowlisting, and HTTPS before public deployment.
- Restrict requests to platforms and paths supported by your application.
- Keep `yt-dlp` pinned and review updates before deployment.
- Only download and share media you have permission to download or distribute.
