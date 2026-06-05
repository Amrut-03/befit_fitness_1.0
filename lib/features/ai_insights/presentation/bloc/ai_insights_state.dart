part of 'ai_insights_bloc.dart';

abstract class AIInsightsState {}

class AIInsightsInitial extends AIInsightsState {}

class AIInsightsLoading extends AIInsightsState {}

class AIInsightsLoaded extends AIInsightsState {
  final List<AIInsightEntity> insights;

  AIInsightsLoaded(this.insights);
}

class AIInsightsError extends AIInsightsState {
  final String message;

  AIInsightsError(this.message);
}
