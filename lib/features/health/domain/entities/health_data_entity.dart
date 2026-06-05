import 'package:equatable/equatable.dart';

class HealthDataEntity extends Equatable {
  final int steps;

  final double calories;

  final int moveMinutes;

  const HealthDataEntity({
    required this.steps,
    required this.calories,
    required this.moveMinutes,
  });

  @override
  List<Object> get props => [steps, calories, moveMinutes];
}
