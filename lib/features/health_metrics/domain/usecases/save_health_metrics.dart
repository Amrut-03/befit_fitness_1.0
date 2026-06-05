import '../entities/health_metrics_entity.dart';

import '../repositories/health_metrics_repository.dart';

class SaveHealthMetric {
  final HealthMetricsRepository repository;

  SaveHealthMetric(this.repository);

  Future<void> call(HealthMetricEntity metric) async {
    await repository.saveMetric(metric);
  }
}
