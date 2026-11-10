import 'package:fitness_app/core/health/health_platform_service.dart';
import 'package:fitness_app/features/health/data/repositories/health_repository_impl.dart';
import 'package:fitness_app/features/health/data/services/pedometer_service.dart';
import 'package:fitness_app/features/health/domain/entities/health_data_entity.dart';
import 'package:fitness_app/features/health/domain/utils/activity_estimator.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'fake_health_platform.dart';

class _MockPedometer extends Mock implements PedometerService {}

class _MockGetUserProfile extends Mock implements GetUserProfile {}

void main() {
  late _MockPedometer pedometer;
  late _MockGetUserProfile getProfile;
  late FakeHealthPlatform platform;
  late HealthRepositoryImpl repo;

  setUp(() {
    pedometer = _MockPedometer();
    getProfile = _MockGetUserProfile();
    platform = FakeHealthPlatform();
    when(() => getProfile()).thenAnswer((_) async => null);
    when(() => pedometer.getTodaySteps()).thenAnswer((_) async => 1234);
    repo = HealthRepositoryImpl(pedometer, getProfile, platform);
  });

  group('getTodayHealthData', () {
    test('uses platform steps and active calories when connected', () async {
      platform
        ..steps = 8000
        ..activeCalories = 312.6;

      final data = await repo.getTodayHealthData();

      expect(data.steps, 8000);
      expect(data.calories, 313);
      expect(data.source, ActivitySource.healthPlatform);
      verifyNever(() => pedometer.getTodaySteps());
    });

    test('estimates calories when the platform has steps only', () async {
      platform
        ..steps = 8000
        ..activeCalories = null;

      final data = await repo.getTodayHealthData();

      expect(
        data.calories,
        ActivityEstimator.calories(
          steps: 8000,
          weightKg: 70,
          heightCm: 170,
        ).roundToDouble(),
      );
      expect(data.source, ActivitySource.healthPlatform);
    });

    test('falls back to the pedometer when not connected', () async {
      platform
        ..currentStatus = HealthPlatformStatus.notConnected
        ..steps = 8000;

      final data = await repo.getTodayHealthData();

      expect(data.steps, 1234);
      expect(data.source, ActivitySource.pedometer);
    });

    test(
      'falls back to the pedometer when the platform has no steps',
      () async {
        platform.steps = 0;

        final data = await repo.getTodayHealthData();

        expect(data.steps, 1234);
        expect(data.source, ActivitySource.pedometer);
      },
    );

    test('falls back to the pedometer when the read fails (null)', () async {
      platform.steps = null;

      expect((await repo.getTodayHealthData()).steps, 1234);
    });
  });

  group('connectPlatform', () {
    test('requests access when not connected', () async {
      platform.currentStatus = HealthPlatformStatus.notConnected;

      expect(await repo.connectPlatform(), HealthPlatformStatus.connected);
      expect(platform.connectCalls, 1);
    });

    test('reports notConnected when the user declines', () async {
      platform
        ..currentStatus = HealthPlatformStatus.notConnected
        ..statusAfterConnect = HealthPlatformStatus.notConnected;

      expect(await repo.connectPlatform(), HealthPlatformStatus.notConnected);
    });

    test('opens the install page when Health Connect is missing', () async {
      platform.currentStatus = HealthPlatformStatus.needsInstall;

      expect(await repo.connectPlatform(), HealthPlatformStatus.needsInstall);
      expect(platform.installCalls, 1);
      expect(platform.connectCalls, 0);
    });

    test('does nothing when unsupported or already connected', () async {
      for (final s in [
        HealthPlatformStatus.unsupported,
        HealthPlatformStatus.connected,
      ]) {
        platform.currentStatus = s;
        expect(await repo.connectPlatform(), s);
      }
      expect(platform.connectCalls, 0);
      expect(platform.installCalls, 0);
    });
  });
}
