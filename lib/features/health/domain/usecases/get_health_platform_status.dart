import 'package:fitness_app/core/health/health_platform_service.dart';

import '../repositories/health_repository.dart';

class GetHealthPlatformStatus {
  final HealthRepository repository;

  GetHealthPlatformStatus(this.repository);

  Future<HealthPlatformStatus> call() => repository.getPlatformStatus();
}
