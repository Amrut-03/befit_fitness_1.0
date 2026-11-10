import 'package:fitness_app/core/di/storage_module.dart';
import 'package:fitness_app/features/profile/data/datasources/local/profile_local_datasources.dart';
import 'package:fitness_app/features/profile/data/datasources/remote/profile_remote_datasources.dart';
import 'package:fitness_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:fitness_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:fitness_app/features/profile/domain/usecases/get_profile.dart';
import 'package:fitness_app/features/profile/domain/usecases/update_profile.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

/// Dependencies for the profile feature.
void registerProfileDependencies(GetIt sl) {
  sl.registerLazySingleton<ProfileLocalDatasource>(
    () => ProfileLocalDatasourceImpl(
      sl<Box>(instanceName: StorageModule.profile),
    ),
  );

  sl.registerLazySingleton<ProfileRemoteDatasource>(
    () => ProfileRemoteDatasourceImpl(sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton(() => GetProfile(sl()));

  sl.registerLazySingleton(() => UpdateProfile(sl()));

  sl.registerFactory(() => ProfileBloc(sl(), sl()));
}
