import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;

class GoogleFitService {
  final GoogleSignIn googleSignIn;

  GoogleFitService({required this.googleSignIn});

  Future<Map<String, dynamic>> fetchTodayData() async {
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
      DateTime.now().day,
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
          {"dataTypeName": "com.google.step_count.delta"},

          {"dataTypeName": "com.google.calories.expended"},
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

    int steps = 0;

    double calories = 0;

    final buckets = data['bucket'];

    for (var bucket in buckets) {
      final datasets = bucket['dataset'];

      for (var dataset in datasets) {
        final points = dataset['point'];

        for (var point in points) {
          final values = point['value'];

          if (values.isNotEmpty) {
            final value = values[0];

            if (value['intVal'] != null) {
              steps += value['intVal'] as int;
            }

            if (value['fpVal'] != null) {
              calories += (value['fpVal'] as num).toDouble();
            }
          }
        }
      }
    }

    return {'steps': steps, 'calories': calories};
  }
}
