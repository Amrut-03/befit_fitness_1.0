import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/local/ai_insights_local_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/remote/ai_insights_remote_datasource.dart';
import 'package:fitness_app/features/ai_insights/domain/entities/ai_insights_entity.dart';
import '../../domain/repositories/ai_insights_repository.dart';

class AIInsightsRepositoryImpl implements AIInsightsRepository {
  final AIInsightsRemoteDatasource remoteDatasource;
  final AIInsightsLocalDatasource localDatasource;
  final String? Function() currentUid;
  final DateTime Function() _now;

  AIInsightsRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.currentUid,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  @override
  Future<List<AIInsightEntity>> getDailyInsights({
    required int steps,
    required int calories,
    required int streak,
    required double bmi,
    bool forceRefresh = false,
  }) async {
    final uid = currentUid();
    if (uid == null) throw const UnauthenticatedException();

    final today = _now();
    if (!forceRefresh) {
      final cached = localDatasource.read(uid: uid, day: today);
      if (cached != null && cached.isNotEmpty) return cached;
    }

    final insights = await remoteDatasource.generateInsights(
      steps: steps,
      calories: calories,
      streak: streak,
      bmi: bmi,
    );
    await localDatasource.write(uid: uid, day: today, insights: insights);
    return insights;
  }
}
