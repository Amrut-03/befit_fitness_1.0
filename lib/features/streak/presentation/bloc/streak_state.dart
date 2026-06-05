import 'package:equatable/equatable.dart';

class StreakState extends Equatable {
  final bool isLoading;

  final int currentStreak;

  final DateTime? lastActiveDate;

  final String? error;

  const StreakState({
    this.isLoading = false,

    this.currentStreak = 0,

    this.lastActiveDate,

    this.error,
  });

  factory StreakState.initial() {
    return const StreakState();
  }

  StreakState copyWith({
    bool? isLoading,

    int? currentStreak,

    DateTime? lastActiveDate,

    String? error,
  }) {
    return StreakState(
      isLoading: isLoading ?? this.isLoading,

      currentStreak: currentStreak ?? this.currentStreak,

      lastActiveDate: lastActiveDate ?? this.lastActiveDate,

      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, currentStreak, lastActiveDate, error];
}
