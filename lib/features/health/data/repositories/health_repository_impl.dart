import 'package:fitness_app/features/onboarding/domain/repositories/onboarding_repository.dart';

import '../services/pedometer_service.dart';

import '../../domain/entities/health_data_entity.dart';

import '../../domain/repositories/health_repository.dart';

import '../../domain/utils/activity_estimator.dart';

class HealthRepositoryImpl implements HealthRepository {
  final PedometerService _pedometerService;
  final OnboardingRepository _onboardingRepository;

  HealthRepositoryImpl(
    this._pedometerService,
    this._onboardingRepository,
  );

  @override
  Future<HealthDataEntity> getTodayHealthData() async {
    final steps = await _pedometerService.getTodaySteps();
    final profile = await _onboardingRepository.getUserProfile();

    final weight = profile?.weight ?? 70;
    final height = profile?.height ?? 170;
    final gender = profile?.gender ?? 'Male';

    return HealthDataEntity(
      steps: steps,
      calories: ActivityEstimator.calories(
        steps: steps,
        weightKg: weight,
        heightCm: height,
        gender: gender,
      ).roundToDouble(),
      moveMinutes: ActivityEstimator.moveMinutes(
        steps: steps,
        heightCm: height,
        gender: gender,
      ),
    );
  }
}
