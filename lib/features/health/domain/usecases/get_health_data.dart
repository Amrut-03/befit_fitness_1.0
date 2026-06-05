import '../entities/health_data_entity.dart';

import '../repositories/health_repository.dart';

class GetHealthData {
  final HealthRepository repository;

  GetHealthData(this.repository);

  Future<HealthDataEntity> call() async {
    return await repository.getTodayHealthData();
  }
}
