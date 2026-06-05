import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/health_metrics/data/datasources/remote/health_metrics_remote_datasource.dart';

import '../../domain/entities/health_metrics_entity.dart';

import '../../domain/repositories/health_metrics_repository.dart';

import '../datasources/local/health_metrics_local_datasource.dart';

import '../models/health_metric_model.dart';

import '../services/google_fit_metrics_service.dart';

class HealthMetricRepositoryImpl implements HealthMetricsRepository {
  final GoogleFitMetricsService googleFitService;

  final HealthMetricsLocalDataSource localDataSource;

  final FirebaseAuth auth;

  final HealthMetricsRemoteDataSource remoteDataSource;

  HealthMetricRepositoryImpl(
    this.googleFitService,

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

    /// GOOGLE FIT METRICS
    List<HealthMetricModel> googleFitMetrics = [];

    try {
      googleFitMetrics = await googleFitService.fetchMetrics();
    } catch (_) {}

    /// MERGE ALL
    final merged = [...localMetrics, ...firebaseMetrics, ...googleFitMetrics];

    /// REMOVE DUPLICATES
    final unique = <String, HealthMetricModel>{};

    for (var metric in merged) {
      unique["${metric.type}_${metric.date}"] = metric;
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
    );

    await localDataSource.saveMetric(model);

    final uid = auth.currentUser?.uid;

    if (uid != null) {
      await remoteDataSource.saveMetric(uid, model);
    }
  }

  @override
  Future<void> deleteMetric(DateTime date) async {
    await localDataSource.deleteMetric(date);
  }
}
