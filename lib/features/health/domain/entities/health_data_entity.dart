import 'package:equatable/equatable.dart';

/// Where today's activity numbers came from.
enum ActivitySource {
  /// Health Connect (Android) / HealthKit (iOS).
  healthPlatform,

  /// The phone's step counter, with calories and minutes estimated.
  pedometer,
}

class HealthDataEntity extends Equatable {
  final int steps;

  final double calories;

  final int moveMinutes;

  final ActivitySource source;

  const HealthDataEntity({
    required this.steps,
    required this.calories,
    required this.moveMinutes,
    this.source = ActivitySource.pedometer,
  });

  @override
  List<Object> get props => [steps, calories, moveMinutes, source];
}
