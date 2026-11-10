import 'package:fitness_app/core/l10n/l10n.dart';
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/workout_history_entity.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/workout_session_store.dart';
import '../../domain/usecases/get_workout_history.dart';
import '../../domain/usecases/save_workout_history.dart';
import '../../domain/utils/session_defaults.dart';

class WorkoutSessionState extends Equatable {
  const WorkoutSessionState({
    this.session,
    this.history = const [],
    this.saving = false,
    this.finished,
    this.message,
  });

  /// The workout in progress; null when none.
  final WorkoutSession? session;

  /// Saved workouts, newest first, for "last time" hints and prefills.
  final List<WorkoutHistoryEntity> history;

  final bool saving;

  /// Set once when a session is saved, for the summary.
  final WorkoutHistoryEntity? finished;

  /// One-off message for a snackbar.
  final String? message;

  bool get isActive => session != null;

  bool contains(String exerciseId) =>
      session?.exercises.any((e) => e.exerciseId == exerciseId) ?? false;

  @override
  List<Object?> get props => [session, history, saving, finished, message];
}

/// Runs a workout session: exercises, sets, the rest timer, and saving it
/// to history. Every change is persisted, so a killed app resumes the
/// session where it left off.
class WorkoutSessionCubit extends Cubit<WorkoutSessionState> {
  WorkoutSessionCubit({
    required WorkoutSessionStore store,
    required SaveWorkoutHistory saveWorkoutHistory,
    required GetWorkoutHistory getWorkoutHistory,
    AppAnalytics analytics = const NoopAnalytics(),
    DateTime Function()? clock,
    Duration saveTimeout = const Duration(seconds: 5),
  }) : _store = store,
       _save = saveWorkoutHistory,
       _analytics = analytics,
       _now = clock ?? DateTime.now,
       _saveTimeout = saveTimeout,
       super(WorkoutSessionState(session: store.read())) {
    _historySub = getWorkoutHistory().listen(
      (h) => emit(_copy(history: h)),
      onError: (_) {}, // Hints are optional.
    );
  }

  final WorkoutSessionStore _store;
  final SaveWorkoutHistory _save;
  final AppAnalytics _analytics;
  final DateTime Function() _now;
  final Duration _saveTimeout;
  StreamSubscription<List<WorkoutHistoryEntity>>? _historySub;

  WorkoutSessionState _copy({
    WorkoutSession? Function()? session,
    List<WorkoutHistoryEntity>? history,
    bool? saving,
    WorkoutHistoryEntity? finished,
    String? message,
  }) {
    return WorkoutSessionState(
      session: session != null ? session() : state.session,
      history: history ?? state.history,
      saving: saving ?? state.saving,
      finished: finished,
      message: message,
    );
  }

  Future<void> _update(WorkoutSession session) async {
    emit(_copy(session: () => session));
    await _store.write(session);
  }

  // Exercises

  /// Adds [exercise], starting a session if none is running. Sets are
  /// prefilled from the last time it was done.
  Future<void> addExercise(ExerciseEntity exercise) async {
    if (state.contains(exercise.id)) return;
    final current = state.session ?? WorkoutSession(startedAt: _now());
    await _update(
      current.copyWith(
        exercises: [
          ...current.exercises,
          SessionExercise(
            exerciseId: exercise.id,
            name: exercise.name,
            bodyPart: exercise.bodyPart,
            gifUrl: exercise.gifUrl,
            sets: SessionDefaults.setsFor(exercise.name, state.history),
          ),
        ],
      ),
    );
  }

  Future<void> removeExercise(int index) async {
    final s = state.session;
    if (s == null || index < 0 || index >= s.exercises.length) return;
    await _update(s.copyWith(exercises: [...s.exercises]..removeAt(index)));
  }

  // Sets

  Future<void> addSet(int exerciseIndex) => _editSets(exerciseIndex, (sets) {
    final last = sets.isEmpty
        ? const SessionSet(reps: SessionDefaults.reps)
        : sets.last;
    return [...sets, SessionSet(reps: last.reps, weightKg: last.weightKg)];
  });

  Future<void> removeSet(int exerciseIndex, int setIndex) =>
      _editSets(exerciseIndex, (sets) {
        if (sets.length <= 1 || setIndex >= sets.length) return sets;
        return [...sets]..removeAt(setIndex);
      });

  Future<void> updateSet(
    int exerciseIndex,
    int setIndex, {
    int? reps,
    double? Function()? weightKg,
  }) => _editSets(exerciseIndex, (sets) {
    if (setIndex >= sets.length) return sets;
    if (reps != null && (reps < 0 || reps > 999)) return sets;
    return [...sets]
      ..[setIndex] = sets[setIndex].copyWith(reps: reps, weightKg: weightKg);
  });

  /// Ticks a set off (starting the rest timer) or un-ticks it.
  Future<void> toggleSet(int exerciseIndex, int setIndex) async {
    final s = state.session;
    if (s == null || exerciseIndex >= s.exercises.length) return;
    final sets = s.exercises[exerciseIndex].sets;
    if (setIndex >= sets.length) return;

    final nowDone = !sets[setIndex].done;
    final exercises = [...s.exercises]
      ..[exerciseIndex] = s.exercises[exerciseIndex].copyWith(
        sets: [...sets]..[setIndex] = sets[setIndex].copyWith(done: nowDone),
      );

    await _update(
      s.copyWith(
        exercises: exercises,
        restEndsAt: nowDone
            ? () => _now().add(Duration(seconds: s.restSeconds))
            : null,
      ),
    );
  }

  Future<void> _editSets(
    int exerciseIndex,
    List<SessionSet> Function(List<SessionSet>) edit,
  ) async {
    final s = state.session;
    if (s == null || exerciseIndex >= s.exercises.length) return;
    final exercise = s.exercises[exerciseIndex];
    final sets = edit(exercise.sets);
    if (identical(sets, exercise.sets)) return;
    await _update(
      s.copyWith(
        exercises: [...s.exercises]
          ..[exerciseIndex] = exercise.copyWith(sets: sets),
      ),
    );
  }

  // Rest timer

  /// Changes the rest length by [seconds] (e.g. ±15). A running rest is
  /// extended or shortened too.
  Future<void> adjustRest(int seconds) async {
    final s = state.session;
    if (s == null) return;
    final rest = (s.restSeconds + seconds).clamp(
      WorkoutSession.minRestSeconds,
      WorkoutSession.maxRestSeconds,
    );
    final now = _now();
    await _update(
      s.copyWith(
        restSeconds: rest,
        restEndsAt: s.isResting(now)
            ? () {
                final end = s.restEndsAt!.add(Duration(seconds: seconds));
                return end.isAfter(now) ? end : null;
              }
            : null,
      ),
    );
  }

  Future<void> skipRest() async {
    final s = state.session;
    if (s == null || s.restEndsAt == null) return;
    await _update(s.copyWith(restEndsAt: () => null));
  }

  // Finish / discard

  /// Saves completed sets to history. Exercises with no completed set are
  /// left out. Offline, the save is queued by Firestore and syncs later.
  Future<void> finish() async {
    final s = state.session;
    if (s == null || state.saving) return;
    if (s.completedSets == 0) {
      emit(_copy(message: AppLocale.l10n.workoutNeedOneSet));
      return;
    }

    final logs = [
      for (final e in s.exercises)
        if (e.doneSets > 0)
          ExerciseLog(
            name: e.name,
            bodyPart: e.bodyPart,
            sets: [
              for (final set in e.sets.where((x) => x.done))
                SetLog(reps: set.reps, weightKg: set.weightKg),
            ],
          ),
    ];
    final now = _now();
    final workout = WorkoutHistoryEntity(
      workoutName: s.title,
      bodyPart: s.mainBodyPart,
      completedAt: now,
      exercises: [for (final l in logs) l.name],
      exerciseLogs: logs,
      durationSeconds: now.difference(s.startedAt).inSeconds,
    );

    emit(_copy(saving: true));
    try {
      await _save(workout).timeout(_saveTimeout);
    } on TimeoutException {
      // Written to Firestore's local cache; it syncs when back online.
    } catch (e) {
      emit(_copy(saving: false, message: Failure.fromException(e).message));
      return;
    }

    await _store.clear();
    unawaited(
      _analytics.logWorkoutSaved(
        bodyPart: workout.bodyPart,
        exerciseCount: logs.length,
      ),
    );
    emit(_copy(session: () => null, saving: false, finished: workout));
  }

  Future<void> discard() async {
    await _store.clear();
    emit(_copy(session: () => null));
  }

  @override
  Future<void> close() async {
    await _historySub?.cancel();
    return super.close();
  }
}
