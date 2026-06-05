part of 'ai_insights_bloc.dart';

abstract class AIInsightsEvent {}

class LoadAIInsightsEvent extends AIInsightsEvent {
  final int steps;

  final int calories;

  final int streak;

  final double bmi;

  LoadAIInsightsEvent({
    required this.steps,

    required this.calories,

    required this.streak,

    required this.bmi,
  });
}
