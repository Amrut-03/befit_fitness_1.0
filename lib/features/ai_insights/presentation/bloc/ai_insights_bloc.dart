import 'package:fitness_app/features/ai_insights/domain/entites/ai_insights_entity.dart';
import 'package:fitness_app/features/ai_insights/domain/usecases/generate_ai_insights.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      );

      emit(AIInsightsLoaded(insights));
    } catch (e) {
      emit(AIInsightsError(e.toString()));
    }
  }
}
