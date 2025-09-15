library wallpaper_manager_flutter;

import 'dart:io';
import 'package:flutter/services.dart';

class WallpaperManagerFlutter {
  static const MethodChannel _channel = MethodChannel('wallpaper_manager_flutter');

  static const int HOME_SCREEN = 1;
  static const int LOCK_SCREEN = 2;
  static const int BOTH_SCREENS = 3;

  Future<void> setwallpaperfromFile(File file, int location) async {
    await _channel.invokeMethod('setWallpaper', {
      'filePath': file.path,
      'location': location,
    });
  }
}
