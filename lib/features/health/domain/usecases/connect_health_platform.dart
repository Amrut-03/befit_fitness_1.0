import 'package:fitness_app/core/health/health_platform_service.dart';

import '../repositories/health_repository.dart';

class ConnectHealthPlatform {
  final HealthRepository repository;

  ConnectHealthPlatform(this.repository);

  Future<HealthPlatformStatus> call() => repository.connectPlatform();
}
