import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/features/health_metrics/data/models/health_metric_model.dart';

abstract class HealthMetricsRemoteDataSource {
  Future<void> saveMetric(String uid, HealthMetricModel metric);

  Future<List<HealthMetricModel>> getMetrics(String uid);
}

class HealthMetricsRemoteDataSourceImpl
    implements HealthMetricsRemoteDataSource {
  final FirebaseFirestore firestore;

  HealthMetricsRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> saveMetric(String uid, HealthMetricModel metric) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('health_metrics')
        .add(metric.toJson());
  }

  @override
  Future<List<HealthMetricModel>> getMetrics(String uid) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('health_metrics')
        .get();

    return snapshot.docs
        .map(
          (e) =>
              HealthMetricModel.fromJson(Map<String, dynamic>.from(e.data())),
        )
        .toList();
  }
}
