import '../entities/health_metrics_entity.dart';

import '../repositories/health_metrics_repository.dart';

class GetHealthMetrics {
  final HealthMetricsRepository repository;

  GetHealthMetrics(this.repository);

  Future<List<HealthMetricEntity>> call(MetricType type) async {
    return await repository.getHealthMetrics(type);
  }
}
