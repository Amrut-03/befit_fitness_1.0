import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Total RAM of the device in MB, or null when unknown.
typedef DeviceMemory = Future<int?> Function();

Future<int?> deviceRamMb() async {
  try {
    final plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) return (await plugin.androidInfo).physicalRamSize;
    if (Platform.isIOS) return (await plugin.iosInfo).physicalRamSize;
  } catch (e) {
    debugPrint('deviceRamMb failed: $e');
  }
  return null;
}
