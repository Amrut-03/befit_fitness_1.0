import 'package:fitness_app/core/health/health_platform_service.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';

import '../../domain/entities/health_data_entity.dart';
import '../../domain/repositories/health_repository.dart';
import '../../domain/utils/activity_estimator.dart';
import '../services/pedometer_service.dart';

class HealthRepositoryImpl implements HealthRepository {
  final PedometerService _pedometerService;
  final GetUserProfile _getUserProfile;
  final HealthPlatformService _platform;

  HealthRepositoryImpl(
    this._pedometerService,
    this._getUserProfile,
    this._platform,
  );

  @override
  Future<HealthDataEntity> getTodayHealthData() async {
    int? platformSteps;
    double? platformCalories;

    if (await _platform.status() == HealthPlatformStatus.connected) {
      platformSteps = await _platform.todaySteps();
      if (platformSteps != null && platformSteps > 0) {
        platformCalories = await _platform.todayActiveCalories();
      }
    }

    // No app writes steps to the store on some phones; the pedometer still
    // counts, so prefer it over showing zero.
    final fromPlatform = platformSteps != null && platformSteps > 0;
    final steps = fromPlatform
        ? platformSteps
        : await _pedometerService.getTodaySteps();

    final profile = await _getUserProfile();
    final weight = profile?.weight ?? 70;
    final height = profile?.height ?? 170;
    final gender = profile?.gender ?? 'Male';

    final calories = platformCalories != null && platformCalories > 0
        ? platformCalories
        : ActivityEstimator.calories(
            steps: steps,
            weightKg: weight,
            heightCm: height,
            gender: gender,
          );

    return HealthDataEntity(
      steps: steps,
      calories: calories.roundToDouble(),
      moveMinutes: ActivityEstimator.moveMinutes(
        steps: steps,
        heightCm: height,
        gender: gender,
      ),
      source: fromPlatform
          ? ActivitySource.healthPlatform
          : ActivitySource.pedometer,
    );
  }

  @override
  Future<HealthPlatformStatus> getPlatformStatus() => _platform.status();

  @override
  Future<HealthPlatformStatus> connectPlatform() async {
    final status = await _platform.status();
    switch (status) {
      case HealthPlatformStatus.needsInstall:
        await _platform.installHealthPlatform();
        return status;
      case HealthPlatformStatus.notConnected:
        await _platform.connect();
        return _platform.status();
      case HealthPlatformStatus.connected:
      case HealthPlatformStatus.unsupported:
        return status;
    }
  }
}
