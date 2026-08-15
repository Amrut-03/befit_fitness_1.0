import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/health_metrics/data/datasources/remote/health_metrics_remote_datasource.dart';

import '../../domain/entities/health_metrics_entity.dart';

import '../../domain/repositories/health_metrics_repository.dart';

import '../datasources/local/health_metrics_local_datasource.dart';

import '../models/health_metric_model.dart';

class HealthMetricRepositoryImpl implements HealthMetricsRepository {
  final HealthMetricsLocalDataSource localDataSource;

  final FirebaseAuth auth;

  final HealthMetricsRemoteDataSource remoteDataSource;

  HealthMetricRepositoryImpl(
    this.localDataSource,

    this.remoteDataSource,

    this.auth,
  );

  @override
  Future<List<HealthMetricEntity>> getHealthMetrics(MetricType type) async {
    /// LOCAL METRICS
    final localMetrics = await localDataSource.getMetrics();

    /// FIREBASE METRICS
    List<HealthMetricModel> firebaseMetrics = [];

    final uid = auth.currentUser?.uid;

    if (uid != null) {
      firebaseMetrics = await remoteDataSource.getMetrics(uid);
    }

    /// MERGE ALL
    final merged = [...localMetrics, ...firebaseMetrics];

    /// REMOVE DUPLICATES
    final unique = <String, HealthMetricModel>{};

    for (var metric in merged) {
      final dateKey = metric.date.toIso8601String();
      unique["${metric.type}_$dateKey"] = metric;
    }

    final finalMetrics = unique.values.toList();

    /// FILTER BY TYPE
    final filtered = finalMetrics.where((e) => e.type == type).toList();

    /// SORT BY DATE
    filtered.sort((a, b) => a.date.compareTo(b.date));

    /// RETURN ENTITY LIST
    return filtered;
  }

@override
  Future<void> saveMetric(HealthMetricEntity metric) async {
    final model = HealthMetricModel(
      type: metric.type,

      date: metric.date,

      value: metric.value,

      isManual: metric.isManual,

      id: '${metric.type.name}_${metric.date.millisecondsSinceEpoch}',
    );

    await localDataSource.saveMetric(model);

    final uid = auth.currentUser?.uid;

    if (uid != null) {
      await remoteDataSource.saveMetric(uid, model);
    }
  }

  Future<void> syncLocalMetrics() async {
    final localMetrics = await localDataSource.getMetrics();

    final uid = auth.currentUser?.uid;

    if (uid == null) {
      return;
    }

    final existingRemote = await remoteDataSource.getMetrics(uid);

    final existingIds = <String>{};
    for (var m in existingRemote) {
      existingIds.add('${m.type}_${m.date.millisecondsSinceEpoch}');
    }

    for (var localMetric in localMetrics) {
      final key = '${localMetric.type}_${localMetric.date.millisecondsSinceEpoch}';
      if (!existingIds.contains(key)) {
        final model = HealthMetricModel(
          type: localMetric.type,

          date: localMetric.date,

          value: localMetric.value,

          isManual: localMetric.isManual,

          id: key,
        );

        await remoteDataSource.saveMetric(uid, model);
      }
    }
  }

  @override
  Future<void> deleteMetric(DateTime date) async {
    await localDataSource.deleteMetric(date);

    final uid = auth.currentUser?.uid;

    if (uid != null) {
      final model = HealthMetricModel(
        type: MetricType.weight,

        date: date,

        value: 0,

        isManual: false,

        id: '${MetricType.weight.name}_${date.millisecondsSinceEpoch}',
      );

      await remoteDataSource.deleteMetric(uid, model);
    }
  }
}
