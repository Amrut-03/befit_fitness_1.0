import 'package:fitness_app/core/di/storage_module.dart';
import 'package:fitness_app/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/local/user_data_local_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/remote/user_data_remote_datasource.dart';
import 'package:fitness_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fitness_app/features/auth/domain/usecases/delete_account.dart';
import 'package:fitness_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_as_guest.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_out.dart';
import 'package:fitness_app/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/notifications/data/models/notification_model.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

/// Dependencies for the auth feature.
void registerAuthDependencies(GetIt sl) {
  sl.registerLazySingleton(
    () => AuthRemoteDataSource(firebaseAuth: sl(), googleSignIn: sl()),
  );

  sl.registerLazySingleton(() => AuthLocalDataSource(sl()));

  sl.registerLazySingleton(() => UserDataRemoteDataSource(firestore: sl()));

  // Every box holding per-user data (see StorageModule.userScoped), so
  // logout and "Delete account" clear them.
  sl.registerLazySingleton(
    () => UserDataLocalDataSource([
      for (final name in StorageModule.userScoped) sl<Box>(instanceName: name),
      sl<Box<NotificationModel>>(),
    ]),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      userDataRemoteDataSource: sl(),
      userDataLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => SignInWithGoogle(sl()));

  sl.registerLazySingleton(() => SignInAsGuest(sl()));

  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  sl.registerLazySingleton(() => WatchAuthState(sl()));

  sl.registerLazySingleton(() => SignOut(sl()));

  sl.registerLazySingleton(() => DeleteAccount(sl()));

  sl.registerFactory(
    () => AuthBloc(
      signInWithGoogle: sl(),
      signInAsGuest: sl(),
      signOut: sl(),
      deleteAccount: sl(),
    ),
  );
}
