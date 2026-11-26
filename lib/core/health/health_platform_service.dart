import 'package:equatable/equatable.dart';

/// Whether BeFit can read from the device health store
/// (Health Connect on Android, HealthKit on iOS).
enum HealthPlatformStatus {
  /// Access granted (on iOS: the authorization sheet has been shown, since
  /// HealthKit never reveals whether read access was granted).
  connected,

  /// Available on this device but the user hasn't granted access yet.
  notConnected,

  /// Android only: Health Connect is missing or needs an update.
  needsInstall,

  /// The device can't use a health store at all.
  unsupported,
}

/// Metrics BeFit reads as daily values for the 7/30-day charts.
enum PlatformMetric { heartRate, sleep, weight }

/// One value per calendar day.
class DailyReading extends Equatable {
  const DailyReading({required this.day, required this.value});

  /// Local midnight of the day the value belongs to.
  final DateTime day;

  /// Heart rate: average bpm. Sleep: hours. Weight: kg.
  final double value;

  @override
  List<Object?> get props => [day, value];
}

/// Read-only access to Health Connect / HealthKit.
///
/// Every read returns `null` (or an empty list) instead of throwing when the
/// store is unavailable or access is missing, so callers can fall back.
abstract class HealthPlatformService {
  Future<HealthPlatformStatus> status();

  /// Shows the system permission sheet. Returns true when access was granted
  /// (on iOS: when the sheet was shown).
  Future<bool> connect();

  /// Android: opens the Play Store page for Health Connect.
  Future<void> installHealthPlatform();

  /// Total steps from local midnight until now.
  Future<int?> todaySteps();

  /// Active (not basal) kcal burned from local midnight until now.
  Future<double?> todayActiveCalories();

  /// Daily values for [metric] between [from] and [to] (inclusive days).
  Future<List<DailyReading>> dailyReadings(
    PlatformMetric metric, {
    required DateTime from,
    required DateTime to,
  });
}
