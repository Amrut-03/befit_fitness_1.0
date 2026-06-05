part of 'health_calculator_bloc.dart';

abstract class HealthCalculatorEvent {}

class CalculateBMIEvent extends HealthCalculatorEvent {
  final double weight;

  final double height;

  CalculateBMIEvent({required this.weight, required this.height});
}

class CalculateWaterEvent extends HealthCalculatorEvent {
  final double weight;

  CalculateWaterEvent({required this.weight});
}

class CalculateProteinEvent extends HealthCalculatorEvent {
  final double weight;

  final String goal;

  CalculateProteinEvent({required this.weight, required this.goal});
}

class CalculateCaloriesEvent extends HealthCalculatorEvent {
  final double weight;

  final double height;

  final int age;

  final String gender;

  final double activity;

  CalculateCaloriesEvent({
    required this.weight,

    required this.height,

    required this.age,

    required this.gender,

    required this.activity,
  });
}
