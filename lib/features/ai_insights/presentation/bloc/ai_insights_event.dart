part of 'ai_insights_bloc.dart';

abstract class AIInsightsEvent {}

class LoadAIInsightsEvent extends AIInsightsEvent {
  final int steps;
  final int calories;
  final int streak;
  final double bmi;

  /// Skip the daily cache (used by the Retry button).
  final bool forceRefresh;

  LoadAIInsightsEvent({
    required this.steps,
    required this.calories,
    required this.streak,
    required this.bmi,
    this.forceRefresh = false,
  });
}
