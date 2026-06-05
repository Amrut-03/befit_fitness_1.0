import '../repositories/health_metrics_repository.dart';

class DeleteHealthMetric {
  final HealthMetricsRepository repository;

  DeleteHealthMetric(this.repository);

  Future<void> call(DateTime date) async {
    await repository.deleteMetric(date);
  }
}
