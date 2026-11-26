import '../entities/coach_delta.dart';

abstract interface class CoachRepository {
  /// Streams an answer to [prompt]: on-device when the model is ready,
  /// otherwise (or when on-device fails before answering) from the cloud.
  Stream<CoachDelta> reply(String prompt);
}
