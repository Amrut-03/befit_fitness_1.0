import 'package:fitness_app/core/health/health_platform_service.dart';

import '../entities/health_data_entity.dart';

abstract class HealthRepository {
  /// Today's activity. Reads Health Connect / HealthKit when connected and
  /// falls back to the pedometer otherwise.
  Future<HealthDataEntity> getTodayHealthData();

  Future<HealthPlatformStatus> getPlatformStatus();

  /// Requests read access, or opens the Health Connect install page when
  /// it's missing. Returns the resulting status.
  Future<HealthPlatformStatus> connectPlatform();
}
