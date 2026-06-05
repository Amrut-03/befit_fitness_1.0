part of 'health_calculator_bloc.dart';

abstract class HealthCalculatorState {}

class HealthCalculatorInitial extends HealthCalculatorState {}

class HealthCalculatorLoaded extends HealthCalculatorState {
  final CalculatorResultEntity result;

  HealthCalculatorLoaded(this.result);
}
