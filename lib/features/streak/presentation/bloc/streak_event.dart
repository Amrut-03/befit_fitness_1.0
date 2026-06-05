import 'package:equatable/equatable.dart';

abstract class StreakEvent extends Equatable {
  const StreakEvent();

  @override
  List<Object?> get props => [];
}

/// LOAD CURRENT STREAK
class LoadStreakEvent extends StreakEvent {}

/// UPDATE STREAK
class UpdateStreakEvent extends StreakEvent {}
