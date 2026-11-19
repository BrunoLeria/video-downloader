import 'package:flutter/material.dart';
import 'package:video_downloader/models/media_info.dart';

class PlatformBadge extends StatelessWidget {
  const PlatformBadge({super.key, required this.platform});

  final SupportedPlatform platform;

  @override
  Widget build(BuildContext context) {
    final label = switch (platform) {
      SupportedPlatform.youtube => 'YouTube',
      SupportedPlatform.instagram => 'Instagram',
      SupportedPlatform.generic => 'Web',
      SupportedPlatform.unsupported => 'Indefinida',
    };

    final icon = switch (platform) {
      SupportedPlatform.youtube => Icons.smart_display,
      SupportedPlatform.instagram => Icons.camera_alt,
      SupportedPlatform.generic => Icons.language,
      SupportedPlatform.unsupported => Icons.help,
    };

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
