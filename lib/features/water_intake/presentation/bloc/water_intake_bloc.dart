import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/water_day.dart';
import '../../domain/entities/water_entry.dart';
import '../../domain/repositories/hydration_reminders.dart';
import '../../domain/usecases/water_usecases.dart';
import '../../domain/utils/water_goal.dart';

part 'water_intake_event.dart';
part 'water_intake_state.dart';

class WaterIntakeBloc extends Bloc<WaterIntakeEvent, WaterIntakeState> {
  WaterIntakeBloc({
    required WatchWaterDay watchDay,
    required GetWaterHistory getHistory,
    required AddWater addWater,
    required RemoveWater removeWater,
    required GetWaterGoal getGoal,
    required GetRecommendedWaterGoal getRecommendedGoal,
    required SetWaterGoal setGoal,
    required HydrationReminders reminders,
    required AppAnalytics analytics,
    DateTime Function()? clock,
  }) : _watchDay = watchDay,
       _getHistory = getHistory,
       _addWater = addWater,
       _removeWater = removeWater,
       _getGoal = getGoal,
       _getRecommendedGoal = getRecommendedGoal,
       _setGoal = setGoal,
       _reminders = reminders,
       _analytics = analytics,
       _now = clock ?? DateTime.now,
       super(const WaterIntakeState()) {
    on<WaterIntakeStarted>(_onStarted);
    on<WaterIntakeRefreshed>(_onRefreshed);
    on<WaterAdded>(_onAdded);
    on<WaterEntryRemoved>(_onRemoved);
    on<WaterGoalUpdated>(_onGoalUpdated);
    on<_WaterDayChanged>(_onDayChanged);
    on<_WaterStreamFailed>(
      (e, emit) => emit(
        state.copyWith(
          status: state.today == null ? WaterStatus.failure : null,
          message: Failure.fromException(e.error).message,
        ),
      ),
    );
  }

  final WatchWaterDay _watchDay;
  final GetWaterHistory _getHistory;
  final AddWater _addWater;
  final RemoveWater _removeWater;
  final GetWaterGoal _getGoal;
  final GetRecommendedWaterGoal _getRecommendedGoal;
  final SetWaterGoal _setGoal;
  final HydrationReminders _reminders;
  final AppAnalytics _analytics;
  final DateTime Function() _now;

  StreamSubscription<WaterDay>? _todaySub;
  DateTime? _subscribedDay;

  DateTime get _today => WaterGoal.startOfDay(_now());

  Future<void> _onStarted(
    WaterIntakeStarted event,
    Emitter<WaterIntakeState> emit,
  ) async {
    emit(state.copyWith(status: WaterStatus.loading));
    try {
      final goal = await _getGoal();
      final recommended = await _getRecommendedGoal();
      emit(state.copyWith(goalMl: goal, recommendedGoalMl: recommended));
      _subscribeToday();
      await _loadHistory(emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: WaterStatus.failure,
          message: Failure.fromException(e).message,
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    WaterIntakeRefreshed event,
    Emitter<WaterIntakeState> emit,
  ) async {
    if (state.status == WaterStatus.initial) return;
    if (_subscribedDay != _today) _subscribeToday();
    try {
      await _loadHistory(emit);
    } catch (_) {
      // History is secondary; keep what's shown.
    }
  }

  Future<void> _onAdded(
    WaterAdded event,
    Emitter<WaterIntakeState> emit,
  ) async {
    // Logging just after midnight: follow the new day so the entry shows.
    if (_subscribedDay != null && _subscribedDay != _today) _subscribeToday();
    try {
      // Resolves once the server acknowledges the write. The snapshot
      // listener shows the new entry immediately, even offline.
      await _addWater(event.ml, goalMl: state.goalMl);
      unawaited(_analytics.logWaterLogged(ml: event.ml));
    } catch (e) {
      emit(state.copyWith(message: _messageFor(e)));
    }
  }

  Future<void> _onRemoved(
    WaterEntryRemoved event,
    Emitter<WaterIntakeState> emit,
  ) async {
    try {
      await _removeWater(state.today?.day ?? _today, event.entry);
    } catch (e) {
      emit(state.copyWith(message: _messageFor(e)));
    }
  }

  Future<void> _onGoalUpdated(
    WaterGoalUpdated event,
    Emitter<WaterIntakeState> emit,
  ) async {
    final previous = state.goalMl;
    final today = state.today;
    final wasReached = today?.goalReached;
    emit(
      state.copyWith(
        goalMl: event.ml,
        today: today == null ? null : _withGoal(today, event.ml),
      ),
    );
    await _syncReminders(wasReached, state.today);
    try {
      await _setGoal(event.ml);
    } catch (e) {
      emit(
        state.copyWith(goalMl: previous, today: today, message: _messageFor(e)),
      );
    }
  }

  Future<void> _onDayChanged(
    _WaterDayChanged event,
    Emitter<WaterIntakeState> emit,
  ) async {
    final wasReached = state.today?.day == event.day.day
        ? state.today?.goalReached
        : null;
    final today = _withGoal(event.day, state.goalMl);
    emit(state.copyWith(status: WaterStatus.ready, today: today));
    await _syncReminders(wasReached, today);
  }

  /// Quiets today's reminders when the goal is first met and restores them
  /// when it no longer is.
  Future<void> _syncReminders(bool? wasReached, WaterDay? today) async {
    if (today == null || today.day != _today) return;
    final reached = today.goalReached;
    if (reached == wasReached) return;
    try {
      if (reached) {
        await _reminders.goalReachedToday();
      } else if (wasReached == true) {
        await _reminders.goalNotReachedToday();
      }
    } catch (_) {
      // Reminders are best effort.
    }
  }

  void _subscribeToday() {
    final day = _today;
    _subscribedDay = day;
    unawaited(_todaySub?.cancel());
    _todaySub = _watchDay(day, goalMl: state.goalMl).listen(
      (d) => add(_WaterDayChanged(d)),
      onError: (Object e) => add(_WaterStreamFailed(e)),
    );
  }

  Future<void> _loadHistory(Emitter<WaterIntakeState> emit) async {
    final history = await _getHistory(days: 7, goalMl: state.goalMl);
    emit(state.copyWith(history: history));
  }

  static WaterDay _withGoal(WaterDay d, int goalMl) =>
      WaterDay(day: d.day, goalMl: goalMl, entries: d.entries);

  static String _messageFor(Object e) => e is ArgumentError
      ? 'Enter an amount between 1 and 3000 ml.'
      : Failure.fromException(e).message;

  @override
  Future<void> close() async {
    await _todaySub?.cancel();
    return super.close();
  }
}
