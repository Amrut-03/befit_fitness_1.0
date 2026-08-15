import 'dart:io' show Platform;

import 'package:pedometer_2/pedometer_2.dart';
import 'package:permission_handler/permission_handler.dart';

class PedometerService {
  /// Returns the number of steps taken since the start of the current day.
  ///
  /// Requests the motion/activity recognition permission when needed.
  /// Returns 0 when the permission is denied or the platform cannot be read.
  Future<int> getTodaySteps() async {
    final granted = await _ensurePermission();
    if (!granted) return 0;

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      return await Pedometer().getStepCount(from: startOfDay, to: now);
    } catch (_) {
      return 0;
    }
  }

  Future<bool> _ensurePermission() async {
    final permission = Platform.isAndroid
        ? Permission.activityRecognition
        : Permission.sensors;

    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied || status.isRestricted) return false;

    final result = await permission.request();
    return result.isGranted;
  }
}
