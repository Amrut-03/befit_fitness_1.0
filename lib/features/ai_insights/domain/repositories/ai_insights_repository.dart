import 'package:fitness_app/features/ai_insights/domain/entites/ai_insights_entity.dart';

abstract class AIInsightsRepository {
  Future<List<AIInsightEntity>> generateInsights({
    required int steps,

    required int calories,

    required int streak,

    required double bmi,
  });
}
