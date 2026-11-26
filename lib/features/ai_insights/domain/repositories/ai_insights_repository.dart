import 'package:fitness_app/features/ai_insights/domain/entities/ai_insights_entity.dart';

abstract class AIInsightsRepository {
  /// Today's insights for the signed-in user: from the daily cache when
  /// available (unless [forceRefresh]), otherwise generated and cached.
  Future<List<AIInsightEntity>> getDailyInsights({
    required int steps,
    required int calories,
    required int streak,
    required double bmi,
    bool forceRefresh = false,
  });
}
