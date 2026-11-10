import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/coach_cloud_datasource.dart';
import 'data/repositories/coach_repository_impl.dart';
import 'domain/repositories/coach_repository.dart';
import 'domain/services/coach_safety.dart';
import 'domain/usecases/ask_coach.dart';
import 'presentation/bloc/coach_bloc.dart';
import 'presentation/cubit/on_device_model_cubit.dart';

/// Dependencies for the AI coach (chat + on-device model management).
void registerAiCoachDependencies(GetIt sl) {
  sl.registerLazySingleton(CoachCloudDatasource.gemini);
  sl.registerLazySingleton<CoachRepository>(
    () => CoachRepositoryImpl(onDevice: sl(), cloud: sl()),
  );
  sl.registerLazySingleton(
    () => AskCoach.localized(
      sl(),
      language: () => AppLocale.languageName,
      cannedText: (kind) => switch (kind) {
        CannedReply.emergency => AppLocale.l10n.coachEmergency,
        CannedReply.professional => AppLocale.l10n.coachProfessional,
      },
    ),
  );
  sl.registerFactory(() => CoachBloc(sl()));
  sl.registerFactory(() => OnDeviceModelCubit(sl()));
}
