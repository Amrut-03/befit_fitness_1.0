import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';

import '../../domain/entities/health_data_entity.dart';
import '../../domain/repositories/health_repository.dart';
import '../../domain/utils/activity_estimator.dart';
import '../services/pedometer_service.dart';

class HealthRepositoryImpl implements HealthRepository {
  final PedometerService _pedometerService;
  final GetUserProfile _getUserProfile;

  HealthRepositoryImpl(this._pedometerService, this._getUserProfile);

  @override
  Future<HealthDataEntity> getTodayHealthData() async {
    final steps = await _pedometerService.getTodaySteps();
    final profile = await _getUserProfile();

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
