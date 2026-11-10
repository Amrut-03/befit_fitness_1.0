import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/config/app_config.dart';
import 'package:fitness_app/features/workout/data/models/exercise_model.dart';
import 'package:fitness_app/features/workout/data/models/workout_history_model.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_page_entity.dart';
import 'package:http/http.dart' as http;

class WorkoutRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final http.Client client;

  WorkoutRemoteDatasource({
    required this.firestore,
    required this.auth,
    http.Client? client,
  }) : client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 15);

  /// Fetches a page of exercises from the open-source ExerciseDB API.
  ///
  /// [bodyPart] is filtered server-side (e.g. `chest`, `upper arms`), and
  /// [cursor] is the `nextCursor` returned by the previous page.
  Future<ExercisePageEntity> getExercises({
    int limit = 20,
    String? cursor,
    String? bodyPart,
  }) async {
    final uri = Uri.parse('${AppConfig.exerciseDbBaseUrl}/exercises').replace(
      queryParameters: {
        'limit': '$limit',
        if (bodyPart != null && bodyPart.trim().isNotEmpty)
          'bodyParts': bodyPart.trim().toLowerCase(),
        if (cursor != null) 'after': cursor,
      },
    );

    final response = await client.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load exercises (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>? ?? const [];
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};

    final exercises = data
        .whereType<Map<String, dynamic>>()
        .map(ExerciseModel.fromJson)
        .toList();

    final hasNext = meta['hasNextPage'] == true;

    return ExercisePageEntity(
      exercises: exercises,
      nextCursor: hasNext ? meta['nextCursor'] as String? : null,
    );
  }

  Stream<List<WorkoutHistoryModel>> getWorkoutHistory() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('workoutHistory')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WorkoutHistoryModel.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> saveWorkoutHistory(WorkoutHistoryModel workout) async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('workoutHistory')
        .add(workout.toJson());
  }
}
