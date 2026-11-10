import 'dart:io';

import 'package:fitness_app/features/ai_insights/domain/entities/ai_insights_entity.dart';
import 'package:fitness_app/features/ai_insights/domain/usecases/generate_ai_insights.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

part 'ai_insights_event.dart';
part 'ai_insights_state.dart';

class AIInsightsBloc extends Bloc<AIInsightsEvent, AIInsightsState> {
  final GenerateAIInsights generateAIInsights;

  AIInsightsBloc(this.generateAIInsights) : super(AIInsightsInitial()) {
    on<LoadAIInsightsEvent>(_onLoadAIInsights);
  }

  Future<void> _onLoadAIInsights(
    LoadAIInsightsEvent event,
    Emitter<AIInsightsState> emit,
  ) async {
    emit(AIInsightsLoading());

    try {
      final insights = await generateAIInsights(
        steps: event.steps,
        calories: event.calories,
        streak: event.streak,
        bmi: event.bmi,
        forceRefresh: event.forceRefresh,
      );

      if (insights.isEmpty) {
        emit(AIInsightsError('No insights today. Try again later.'));
      } else {
        emit(AIInsightsLoaded(insights));
      }
    } catch (e) {
      if (isOfflineError(e)) {
        emit(
          AIInsightsError(
            'You\'re offline. Insights will load when you\'re back online, or download the on-device model in AI Coach to get them offline.',
            offline: true,
          ),
        );
      } else {
        emit(AIInsightsError('Couldn\'t load AI insights right now.'));
      }
    }
  }

  static bool isOfflineError(Object e) {
    if (e is SocketException || e is http.ClientException) return true;
    final s = e.toString();
    return s.contains('SocketException') ||
        s.contains('Failed host lookup') ||
        s.contains('Network is unreachable');
  }
}
