import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fitness_app/features/streak/domain/usecases/get_streak.dart';

import 'package:fitness_app/features/streak/domain/usecases/update_streak.dart';

import 'streak_event.dart';

import 'streak_state.dart';

class StreakBloc extends Bloc<StreakEvent, StreakState> {
  final GetStreak getStreak;

  final UpdateStreak updateStreak;

  StreakBloc({required this.getStreak, required this.updateStreak})
    : super(StreakState.initial()) {
    on<LoadStreakEvent>(_onLoadStreak);

    on<UpdateStreakEvent>(_onUpdateStreak);
  }

  /// LOAD STREAK
  Future<void> _onLoadStreak(
    LoadStreakEvent event,

    Emitter<StreakState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final streak = await getStreak();

      print("LOADED STREAK = ${state.currentStreak}");

      emit(
        state.copyWith(
          isLoading: false,

          currentStreak: streak.currentStreak,

          lastActiveDate: streak.lastActiveDate,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// UPDATE STREAK
  Future<void> _onUpdateStreak(
    UpdateStreakEvent event,

    Emitter<StreakState> emit,
  ) async {
    try {
      await updateStreak();

      final updated = await getStreak();

      emit(
        state.copyWith(
          currentStreak: updated.currentStreak,

          lastActiveDate: updated.lastActiveDate,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
