import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/local/ai_insights_local_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/on_device/ai_insights_on_device_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/remote/ai_insights_remote_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/models/ai_insight_model.dart';
import 'package:fitness_app/features/ai_insights/domain/entities/ai_insights_entity.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/ai_insights_repository.dart';

class AIInsightsRepositoryImpl implements AIInsightsRepository {
  final AIInsightsRemoteDatasource remoteDatasource;
  final AIInsightsLocalDatasource localDatasource;

  /// Tried first when the model is downloaded; Gemini is the fallback.
  final AIInsightsOnDeviceDatasource? onDeviceDatasource;
  final String? Function() currentUid;
  final DateTime Function() _now;

  AIInsightsRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    this.onDeviceDatasource,
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

    List<AIInsightModel>? insights;
    final onDevice = onDeviceDatasource;
    if (onDevice != null && await onDevice.isReady) {
      try {
        insights = await onDevice.generateInsights(
          steps: steps,
          calories: calories,
          streak: streak,
          bmi: bmi,
        );
      } catch (e) {
        debugPrint('On-device insights failed, using Gemini: $e');
      }
    }
    insights ??= await remoteDatasource.generateInsights(
      steps: steps,
      calories: calories,
      streak: streak,
      bmi: bmi,
    );
    await localDatasource.write(uid: uid, day: today, insights: insights);
    return insights;
  }
}
