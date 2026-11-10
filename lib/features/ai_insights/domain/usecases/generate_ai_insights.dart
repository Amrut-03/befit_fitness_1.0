import 'package:fitness_app/features/ai_insights/domain/entities/ai_insights_entity.dart';
import '../repositories/ai_insights_repository.dart';

class GenerateAIInsights {
  final AIInsightsRepository repository;

  GenerateAIInsights(this.repository);

  Future<List<AIInsightEntity>> call({
    required int steps,
    required int calories,
    required int streak,
    required double bmi,
    bool forceRefresh = false,
  }) {
    return repository.getDailyInsights(
      steps: steps,
      calories: calories,
      streak: streak,
      bmi: bmi,
      forceRefresh: forceRefresh,
    );
  }
}
