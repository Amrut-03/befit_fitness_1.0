import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/config/app_config.dart';
import 'package:fitness_app/core/config/secrets.dart';
import 'package:fitness_app/features/workout/data/models/exercise_model.dart';
import 'package:fitness_app/features/workout/data/models/workout_history_model.dart';
import 'package:http/http.dart' as http;

class WorkoutRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  WorkoutRemoteDatasource({required this.firestore, required this.auth});

  final Map<String, String> _headers = {
    'X-RapidAPI-Key': Secrets.exerciseDbApiKey,
    'X-RapidAPI-Host': AppConfig.exerciseDbHost,
  };

  Future<List<ExerciseModel>> getExercises({
    int limit = 20,
    int offset = 0,
    String? bodyPart,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.exerciseDbBaseUrl}/exercises?limit=$limit&offset=$offset',
      ),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<ExerciseModel> exercises = List<ExerciseModel>.from(
        data.map((e) => ExerciseModel.fromJson(e)),
      );

      if (bodyPart != null && bodyPart.isNotEmpty) {
        final normalized = bodyPart.toLowerCase().trim();

        exercises = exercises.where((exercise) {
          final apiBodyPart = exercise.bodyPart.toLowerCase().trim();
          return apiBodyPart.contains(normalized);
        }).toList();
      }

      return exercises;
    }

    throw Exception('Failed to load exercises');
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
