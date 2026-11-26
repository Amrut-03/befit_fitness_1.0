import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/health/health_platform_service.dart';
import 'package:fitness_app/features/health_metrics/data/datasources/local/health_metrics_local_datasource.dart';
import 'package:fitness_app/features/health_metrics/data/datasources/remote/health_metrics_remote_datasource.dart';
import 'package:fitness_app/features/health_metrics/data/models/health_metric_model.dart';
import 'package:fitness_app/features/health_metrics/data/repositories/health_metric_repository_impl.dart';
import 'package:fitness_app/features/health_metrics/domain/entities/health_metrics_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../health/fake_health_platform.dart';

class _MockLocal extends Mock implements HealthMetricsLocalDataSource {}

class _MockRemote extends Mock implements HealthMetricsRemoteDataSource {}

class _MockAuth extends Mock implements FirebaseAuth {}

void main() {
  final now = DateTime(2026, 11, 10, 12);
  late _MockLocal local;
  late FakeHealthPlatform platform;

  HealthMetricRepositoryImpl repo() {
    final auth = _MockAuth();
    when(() => auth.currentUser).thenReturn(null);
    return HealthMetricRepositoryImpl(
      local,
      _MockRemote(),
      auth,
      healthPlatform: platform,
      clock: () => now,
    );
  }

  setUp(() {
    local = _MockLocal();
    platform = FakeHealthPlatform(
      readings: {
        PlatformMetric.weight: [
          DailyReading(day: DateTime(2026, 11, 8), value: 71),
          DailyReading(day: DateTime(2026, 11, 9), value: 70.5),
        ],
      },
    );
  });

  test('adds platform days, sorted, marked as not manual', () async {
    when(() => local.getMetrics()).thenAnswer((_) async => []);

    final metrics = await repo().getHealthMetrics(MetricType.weight);

    expect(metrics.map((m) => m.value), [71, 70.5]);
    expect(metrics.every((m) => !m.isManual), isTrue);
    expect(platform.readRequests.single.$1, PlatformMetric.weight);
    expect(
      platform.readRequests.single.$2,
      now.subtract(HealthMetricRepositoryImpl.platformWindow),
    );
  });

  test('a manual entry wins over the platform on the same day', () async {
    when(() => local.getMetrics()).thenAnswer(
      (_) async => [
        HealthMetricModel(
          type: MetricType.weight,
          date: DateTime(2026, 11, 9, 8, 15),
          value: 69.9,
          isManual: true,
        ),
      ],
    );

    final metrics = await repo().getHealthMetrics(MetricType.weight);

    expect(metrics.map((m) => (m.value, m.isManual)), [
      (71, false),
      (69.9, true),
    ]);
  });

  test('skips the platform when it is not connected', () async {
    platform.currentStatus = HealthPlatformStatus.notConnected;
    when(() => local.getMetrics()).thenAnswer((_) async => []);

    expect(await repo().getHealthMetrics(MetricType.weight), isEmpty);
    expect(platform.readRequests, isEmpty);
  });
}
