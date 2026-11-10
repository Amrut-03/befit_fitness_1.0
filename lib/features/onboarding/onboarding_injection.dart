import 'package:fitness_app/features/onboarding/data/datasources/remote/onboarding_remote_data_source.dart';
import 'package:fitness_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:fitness_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/is_profile_completed.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/save_user_profile.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:get_it/get_it.dart';

/// Dependencies for the onboarding feature.
void registerOnboardingDependencies(GetIt sl) {
  /// REMOTE DATASOURCE
  sl.registerLazySingleton(
    () => OnboardingRemoteDatasource(firestore: sl(), auth: sl()),
  );

  /// REPOSITORY
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(remoteDatasource: sl()),
  );

  /// USECASES
  sl.registerLazySingleton(() => SaveUserProfile(sl()));

  sl.registerLazySingleton(() => GetUserProfile(sl()));

  sl.registerLazySingleton(() => IsProfileCompleted(sl()));

  /// BLOC
  sl.registerFactory(
    () => OnboardingProfileBloc(
      saveUserProfile: sl(),

      getUserProfile: sl(),

      isProfileCompleted: sl(),
    ),
  );
}
