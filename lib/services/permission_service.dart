import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestDownloadPermissions() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      final sdkInt = info.version.sdkInt;
      if (sdkInt >= 33) {
        return true;
      }

      final status = await Permission.storage.request();
      return status.isGranted || status.isLimited;
    }

    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    }

    return true;
  }

  static Future<Directory> ensureDirectory(String? customDirectory) async {
    Directory targetDir;
    if (customDirectory != null && customDirectory.trim().isNotEmpty) {
      targetDir = Directory(customDirectory);
    } else if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      targetDir = Directory('${externalDir?.path ?? (await getApplicationDocumentsDirectory()).path}/Downloads');
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
      targetDir = Directory('${docsDir.path}/Downloads');
    }

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }
}
