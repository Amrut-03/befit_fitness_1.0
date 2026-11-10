import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/di/storage_module.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/local/ai_insights_local_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/on_device/ai_insights_on_device_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/remote/ai_insights_remote_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/repositories/ai_insights_repository_impl.dart';
import 'package:fitness_app/features/ai_insights/domain/repositories/ai_insights_repository.dart';
import 'package:fitness_app/features/ai_insights/domain/usecases/generate_ai_insights.dart';
import 'package:fitness_app/features/ai_insights/presentation/bloc/ai_insights_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

/// Dependencies for the ai insights feature.
void registerAiInsightsDependencies(GetIt sl) {
  sl.registerLazySingleton(
    () => AIInsightsRemoteDatasource(AIInsightsRemoteDatasource.createModel()),
  );

  sl.registerLazySingleton<AIInsightsRepository>(
    () => AIInsightsRepositoryImpl(
      remoteDatasource: sl(),
      onDeviceDatasource: AIInsightsOnDeviceDatasource(sl()),
      localDatasource: AIInsightsLocalDatasource(
        sl<Box>(instanceName: StorageModule.aiInsights),
      ),
      currentUid: () => sl<FirebaseAuth>().currentUser?.uid,
    ),
  );

  sl.registerLazySingleton(() => GenerateAIInsights(sl()));

  sl.registerFactory(() => AIInsightsBloc(sl()));
}
