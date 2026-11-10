import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/config/app_config.dart';
import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/core/network/api_client.dart';
import 'package:fitness_app/features/workout/data/models/exercise_model.dart';
import 'package:fitness_app/features/workout/data/models/workout_history_model.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_page_entity.dart';

class WorkoutRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ApiClient api;

  WorkoutRemoteDatasource({
    required this.firestore,
    required this.auth,
    ApiClient? api,
  }) : api = api ?? ApiClient();

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
        'after': ?cursor,
      },
    );

    final body = await api.getJson(uri);
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

  String get _uid {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw const UnauthenticatedException();
    return uid;
  }

  /// Builds the query when the stream is listened to, so a missing user
  /// surfaces as a stream error instead of a synchronous throw.
  Stream<T> _userStream<T>(Stream<T> Function() build) =>
      Stream<void>.value(null).asyncExpand((_) => build());

  Stream<List<WorkoutHistoryModel>> getWorkoutHistory() {
    return _userStream(
      () => firestore
          .collection('users')
          .doc(_uid)
          .collection('workoutHistory')
          .orderBy('completedAt', descending: true)
          .snapshots(),
    ).map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkoutHistoryModel.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> saveWorkoutHistory(WorkoutHistoryModel workout) async {
    await firestore
        .collection('users')
        .doc(_uid)
        .collection('workoutHistory')
        .add(workout.toJson());
  }
}
