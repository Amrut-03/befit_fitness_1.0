import '../entities/health_data_entity.dart';

abstract class HealthRepository {
  Future<HealthDataEntity> getTodayHealthData();
}
