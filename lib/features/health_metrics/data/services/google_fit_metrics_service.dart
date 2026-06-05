import 'dart:convert';
import 'package:fitness_app/features/health_metrics/data/models/health_metric_model.dart';
import 'package:fitness_app/features/health_metrics/domain/entities/health_metrics_entity.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleFitMetricsService {
  final GoogleSignIn googleSignIn;

  GoogleFitMetricsService({required this.googleSignIn});

  Future<List<HealthMetricModel>> fetchMetrics() async {
    GoogleSignInAccount? account = googleSignIn.currentUser;

    account ??= await googleSignIn.signInSilently();

    if (account == null) {
      throw Exception("User not signed in");
    }

    final auth = await account.authentication;

    final accessToken = auth.accessToken;

    if (accessToken == null) {
      throw Exception("Access token missing");
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final start = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day - 7,
    ).millisecondsSinceEpoch;

    final response = await http.post(
      Uri.parse(
        'https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate',
      ),

      headers: {
        'Authorization': 'Bearer $accessToken',

        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        "aggregateBy": [
          {"dataTypeName": "com.google.heart_rate.bpm"},

          {"dataTypeName": "com.google.weight"},
        ],

        "bucketByTime": {"durationMillis": 86400000},

        "startTimeMillis": start,

        "endTimeMillis": now,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);

    final List<HealthMetricModel> metrics = [];

    final buckets = data['bucket'];

    for (var bucket in buckets) {
      final datasets = bucket['dataset'];

      for (var dataset in datasets) {
        final points = dataset['point'];

        for (var point in points) {
          final dataType = point['dataTypeName'];

          final values = point['value'];

          if (values.isEmpty) {
            continue;
          }

          final value = values[0];

          final date = DateTime.fromMillisecondsSinceEpoch(
            int.parse(point['endTimeNanos'].toString().substring(0, 13)),
          );

          if (dataType == 'com.google.heart_rate.bpm') {
            metrics.add(
              HealthMetricModel(
                type: MetricType.heartRate,

                value: (value['fpVal'] as num).toDouble(),

                date: date,

                isManual: false,
              ),
            );
          }

          if (dataType == 'com.google.weight') {
            metrics.add(
              HealthMetricModel(
                type: MetricType.weight,

                value: (value['fpVal'] as num).toDouble(),

                date: date,

                isManual: false,
              ),
            );
          }
        }
      }
    }

    print("Metrics $metrics");
    return metrics;
  }
}
