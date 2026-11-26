import '../entities/workout_session.dart';

/// Keeps the in-progress session on the device so it survives the app being
/// closed or killed mid-workout.
abstract class WorkoutSessionStore {
  WorkoutSession? read();

  Future<void> write(WorkoutSession session);

  Future<void> clear();
}
