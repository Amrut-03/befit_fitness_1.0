import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:hive/hive.dart';

import 'daily_aggregation.dart';
import 'health_platform_service.dart';

/// [HealthPlatformService] backed by the `health` plugin.
class HealthPluginService implements HealthPlatformService {
  HealthPluginService(this._prefs, {Health? health})
    : _health = health ?? Health();

  final Health _health;

  /// Device-level box (not cleared on logout: health-store access belongs to
  /// the device, not the BeFit account).
  final Box _prefs;

  static const _iosRequestedKey = 'healthkit_requested';

  bool _configured = false;

  static List<HealthDataType> get _sleepTypes => Platform.isAndroid
      ? const [HealthDataType.SLEEP_SESSION]
      : const [
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_REM,
        ];

  static List<HealthDataType> get _readTypes => [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.WEIGHT,
    ..._sleepTypes,
  ];

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<HealthPlatformStatus> status() async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        return HealthPlatformStatus.unsupported;
      }
      await _configure();

      if (Platform.isAndroid) {
        final sdk = await _health.getHealthConnectSdkStatus();
        if (sdk ==
            HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
          return HealthPlatformStatus.needsInstall;
        }
        if (sdk != HealthConnectSdkStatus.sdkAvailable) {
          // Health Connect ships with Android 14+; on 10–13 it's a Play app.
          return sdk == HealthConnectSdkStatus.sdkUnavailable
              ? HealthPlatformStatus.needsInstall
              : HealthPlatformStatus.unsupported;
        }
        final granted = await _health.hasPermissions(_readTypes);
        return granted == true
            ? HealthPlatformStatus.connected
            : HealthPlatformStatus.notConnected;
      }

      // HealthKit hides read-permission status, so "connected" means the
      // authorization sheet has been shown once.
      return _prefs.get(_iosRequestedKey, defaultValue: false) == true
          ? HealthPlatformStatus.connected
          : HealthPlatformStatus.notConnected;
    } catch (e, s) {
      _log('Health platform status failed', e, s);
      return HealthPlatformStatus.unsupported;
    }
  }

  @override
  Future<bool> connect() async {
    try {
      await _configure();
      final granted = await _health.requestAuthorization(
        _readTypes,
        permissions: List.filled(_readTypes.length, HealthDataAccess.READ),
      );
      if (Platform.isIOS) {
        await _prefs.put(_iosRequestedKey, true);
        return true;
      }
      return granted;
    } catch (e, s) {
      _log('Health platform authorization failed', e, s);
      return false;
    }
  }

  @override
  Future<void> installHealthPlatform() => _health.installHealthConnect();

  @override
  Future<int?> todaySteps() async {
    try {
      await _configure();
      final now = DateTime.now();
      return await _health.getTotalStepsInInterval(_midnight(now), now);
    } catch (e, s) {
      _log('Reading steps failed', e, s);
      return null;
    }
  }

  @override
  Future<double?> todayActiveCalories() async {
    try {
      await _configure();
      final now = DateTime.now();
      final start = _midnight(now);
      // One bucket spanning the day; the platforms' aggregate queries
      // de-duplicate overlapping sources (phone + watch).
      final points = await _health.getHealthIntervalDataFromTypes(
        startDate: start,
        endDate: now,
        types: const [HealthDataType.ACTIVE_ENERGY_BURNED],
        interval: now.difference(start).inSeconds + 1,
      );
      if (points.isEmpty) return null;
      return points.fold<double>(0, (sum, p) => sum + _numeric(p));
    } catch (e, s) {
      _log('Reading active calories failed', e, s);
      return null;
    }
  }

  @override
  Future<List<DailyReading>> dailyReadings(
    PlatformMetric metric, {
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      await _configure();
      final firstDay = _midnight(from);
      final endExclusive = _midnight(to).add(const Duration(days: 1));

      // A night credited to `firstDay` started the evening before.
      final queryStart = metric == PlatformMetric.sleep
          ? firstDay.subtract(const Duration(hours: 12))
          : firstDay;

      final points = await _health.getHealthDataFromTypes(
        types: switch (metric) {
          PlatformMetric.heartRate => const [HealthDataType.HEART_RATE],
          PlatformMetric.weight => const [HealthDataType.WEIGHT],
          PlatformMetric.sleep => _sleepTypes,
        },
        startTime: queryStart,
        endTime: endExclusive,
      );

      final samples = [
        for (final p in points)
          RawSample(from: p.dateFrom, to: p.dateTo, value: _numeric(p)),
      ];

      final readings = switch (metric) {
        PlatformMetric.heartRate => DailyAggregation.average(samples),
        PlatformMetric.weight => DailyAggregation.latest(samples),
        PlatformMetric.sleep => DailyAggregation.sleepHours(samples),
      };

      return readings
          .where(
            (r) => !r.day.isBefore(firstDay) && r.day.isBefore(endExclusive),
          )
          .toList();
    } catch (e, s) {
      _log('Reading ${metric.name} failed', e, s);
      return const [];
    }
  }

  static void _log(String message, Object e, StackTrace s) =>
      debugPrint('HealthPluginService: $message: $e\n$s');

  static DateTime _midnight(DateTime t) => DateTime(t.year, t.month, t.day);

  static double _numeric(HealthDataPoint p) {
    final v = p.value;
    return v is NumericHealthValue ? v.numericValue.toDouble() : 0;
  }
}
