import 'package:hive/hive.dart';

import '../../models/health_metric_model.dart';

abstract class HealthMetricsLocalDataSource {
  Future<void> saveMetric(HealthMetricModel metric);

  Future<List<HealthMetricModel>> getMetrics();

  Future<void> deleteMetric(DateTime date);
}

class HealthMetricsLocalDataSourceImpl implements HealthMetricsLocalDataSource {
  final Box box;

  HealthMetricsLocalDataSourceImpl(this.box);

  static const String metricsKey = 'health_metrics';

  @override
  Future<void> saveMetric(HealthMetricModel metric) async {
    final existing = await getMetrics();

    existing.add(metric);

    final jsonList = existing.map((e) => e.toJson()).toList();

    await box.put(metricsKey, jsonList);
  }

  @override
  Future<List<HealthMetricModel>> getMetrics() async {
    final data = box.get(metricsKey);

    if (data == null) {
      return [];
    }

    final list = List.from(data);

    return list.map((e) {
      final map = Map<String, dynamic>.from(e as Map);

      return HealthMetricModel.fromJson(map);
    }).toList();
  }

  @override
  Future<void> deleteMetric(DateTime date) async {
    final metrics = await getMetrics();

    metrics.removeWhere((e) => e.date == date);

    final jsonList = metrics.map((e) => e.toJson()).toList();

    await box.put(metricsKey, jsonList);
  }
}
