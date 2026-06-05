import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/calculator_result_entity.dart';

import '../../domain/usecases/calculate_bmi.dart';

import '../../domain/usecases/calculate_calories.dart';

import '../../domain/usecases/calculate_protein.dart';

import '../../domain/usecases/calculate_water_intake.dart';

part 'health_calculator_event.dart';

part 'health_calculator_state.dart';

class HealthCalculatorBloc
    extends Bloc<HealthCalculatorEvent, HealthCalculatorState> {
  final CalculateBMI calculateBMI;

  final CalculateWaterIntake calculateWaterIntake;

  final CalculateProtein calculateProtein;

  final CalculateCalories calculateCalories;

  HealthCalculatorBloc(
    this.calculateBMI,

    this.calculateWaterIntake,

    this.calculateProtein,

    this.calculateCalories,
  ) : super(HealthCalculatorInitial()) {
    on<CalculateBMIEvent>(_onCalculateBMI);

    on<CalculateWaterEvent>(_onCalculateWater);

    on<CalculateProteinEvent>(_onCalculateProtein);

    on<CalculateCaloriesEvent>(_onCalculateCalories);
  }

  Future<void> _onCalculateBMI(
    CalculateBMIEvent event,

    Emitter<HealthCalculatorState> emit,
  ) async {
    final result = await calculateBMI(
      weight: event.weight,

      height: event.height,
    );

    emit(HealthCalculatorLoaded(result));
  }

  Future<void> _onCalculateWater(
    CalculateWaterEvent event,

    Emitter<HealthCalculatorState> emit,
  ) async {
    final result = calculateWaterIntake(weight: event.weight);

    emit(HealthCalculatorLoaded(await result));
  }

  void _onCalculateProtein(
    CalculateProteinEvent event,

    Emitter<HealthCalculatorState> emit,
  ) async {
    final result = calculateProtein(weight: event.weight, goal: event.goal);

    emit(HealthCalculatorLoaded(await result));
  }

  void _onCalculateCalories(
    CalculateCaloriesEvent event,

    Emitter<HealthCalculatorState> emit,
  ) async {
    final result = calculateCalories(
      weight: event.weight,

      height: event.height,

      age: event.age,

      gender: event.gender,

      activity: event.activity,
    );

    emit(HealthCalculatorLoaded(await result));
  }
}
