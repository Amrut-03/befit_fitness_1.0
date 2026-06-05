import 'package:equatable/equatable.dart';

class StreakEntity extends Equatable {
  final int currentStreak;

  final DateTime? lastActiveDate;

  const StreakEntity({
    required this.currentStreak,

    required this.lastActiveDate,
  });

  @override
  List<Object?> get props => [currentStreak, lastActiveDate];
}
