import 'package:fitness_app/core/health/health_platform_service.dart';

/// In-memory [HealthPlatformService] for tests.
class FakeHealthPlatform implements HealthPlatformService {
  FakeHealthPlatform({
    this.currentStatus = HealthPlatformStatus.connected,
    this.steps,
    this.activeCalories,
    this.readings = const {},
    this.statusAfterConnect = HealthPlatformStatus.connected,
  });

  HealthPlatformStatus currentStatus;
  HealthPlatformStatus statusAfterConnect;
  int? steps;
  double? activeCalories;
  Map<PlatformMetric, List<DailyReading>> readings;

  int connectCalls = 0;
  int installCalls = 0;
  final readRequests = <(PlatformMetric, DateTime, DateTime)>[];

  @override
  Future<HealthPlatformStatus> status() async => currentStatus;

  @override
  Future<bool> connect() async {
    connectCalls++;
    currentStatus = statusAfterConnect;
    return currentStatus == HealthPlatformStatus.connected;
  }

  @override
  Future<void> installHealthPlatform() async => installCalls++;

  @override
  Future<int?> todaySteps() async => steps;

  @override
  Future<double?> todayActiveCalories() async => activeCalories;

  @override
  Future<List<DailyReading>> dailyReadings(
    PlatformMetric metric, {
    required DateTime from,
    required DateTime to,
  }) async {
    readRequests.add((metric, from, to));
    return readings[metric] ?? const [];
  }
}
