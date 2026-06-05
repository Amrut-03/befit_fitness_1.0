import 'package:fitness_app/features/ai_insights/data/datasources/remote/ai_insights_remote_datasource.dart';
import 'package:fitness_app/features/ai_insights/domain/entites/ai_insights_entity.dart';
import '../../domain/repositories/ai_insights_repository.dart';

class AIInsightsRepositoryImpl implements AIInsightsRepository {
  final AIInsightsRemoteDatasource remoteDatasource;

  AIInsightsRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<AIInsightEntity>> generateInsights({
    required int steps,

    required int calories,

    required int streak,

    required double bmi,
  }) async {
    return await remoteDatasource.generateInsights(
      steps: steps,

      calories: calories,

      streak: streak,

      bmi: bmi,
    );
  }
}
