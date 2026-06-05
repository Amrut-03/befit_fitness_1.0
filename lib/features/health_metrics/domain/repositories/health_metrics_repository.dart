import '../entities/health_metrics_entity.dart';

abstract class HealthMetricsRepository {
  Future<List<HealthMetricEntity>> getHealthMetrics(MetricType type);

  Future<void> saveMetric(HealthMetricEntity metric);

  Future<void> deleteMetric(DateTime date);
}
