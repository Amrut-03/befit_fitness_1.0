import '../../domain/entities/health_data_entity.dart';

import '../../domain/repositories/health_repository.dart';

import '../services/google_fit_service.dart';

class HealthRepositoryImpl implements HealthRepository {
  final GoogleFitService service;

  HealthRepositoryImpl(this.service);

  @override
  Future<HealthDataEntity> getTodayHealthData() async {
    final result = await service.fetchTodayData();

    return HealthDataEntity(
      steps: result['steps'],

      calories: result['calories'],

      moveMinutes: (result['steps'] / 100).toInt(),
    );
  }
}
