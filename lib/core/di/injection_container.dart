import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/remote/ai_insights_remote_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/repositories/ai_insights_repository_impl.dart';
import 'package:fitness_app/features/ai_insights/domain/repositories/ai_insights_repository.dart';
import 'package:fitness_app/features/ai_insights/domain/usecases/generate_ai_insights.dart';
import 'package:fitness_app/features/ai_insights/presentation/bloc/ai_insights_bloc.dart';
import 'package:fitness_app/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:fitness_app/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:fitness_app/features/diet/data/datasources/remote/diet_remote_datasource.dart';
import 'package:fitness_app/features/diet/data/repositories/diet_repository_impl.dart';
import 'package:fitness_app/features/diet/domain/repositories/diet_repository.dart';
import 'package:fitness_app/features/diet/domain/usecases/delete_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/get_diet_history.dart';
import 'package:fitness_app/features/diet/domain/usecases/get_diet_plans.dart';
import 'package:fitness_app/features/diet/domain/usecases/get_todays_macros.dart';
import 'package:fitness_app/features/diet/domain/usecases/save_diet_history.dart';
import 'package:fitness_app/features/diet/domain/usecases/save_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/set_active_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/update_meal_status.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/food_item/data/datasources/local/food_item_local_datasource.dart';
import 'package:fitness_app/features/food_item/data/datasources/remote/food_item_remote_datasource_impl.dart';
import 'package:fitness_app/features/food_item/data/repositories/food_items_repository_impl.dart';
import 'package:fitness_app/features/food_item/domain/repositories/food_item_repository.dart';
import 'package:fitness_app/features/food_item/domain/usecases/delete_food_item.dart';
import 'package:fitness_app/features/food_item/domain/usecases/get_food_items.dart';
import 'package:fitness_app/features/food_item/domain/usecases/save_food_item.dart';
import 'package:fitness_app/features/food_item/domain/usecases/update_food_item.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_bloc.dart';
import 'package:fitness_app/features/food_scanner/data/datasources/remote/food_scanner_remote_datasource.dart';
import 'package:fitness_app/features/food_scanner/data/repositories/food_scanner_repository_impl.dart';
import 'package:fitness_app/features/food_scanner/domain/repositories/food_scanner_repository.dart';
import 'package:fitness_app/features/food_scanner/domain/usecases/scan_barcode.dart';
import 'package:fitness_app/features/food_scanner/presentation/bloc/food_scanner_bloc.dart';
import 'package:fitness_app/features/health/data/repositories/health_repository_impl.dart';
import 'package:fitness_app/features/health/data/services/google_fit_service.dart';
import 'package:fitness_app/features/health/domain/repositories/health_repository.dart';
import 'package:fitness_app/features/health/domain/usecases/get_health_data.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health_calculator/data/datasources/local/health_calculator_local_datasource.dart';
import 'package:fitness_app/features/health_calculator/data/repositories/health_calculator_repository_impl.dart';
import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_reposittory.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_bmi.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_calories.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_protein.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_water_intake.dart';
import 'package:fitness_app/features/health_calculator/presentation/bloc/health_calculator_bloc.dart';
import 'package:fitness_app/features/health_metrics/data/datasources/local/health_metrics_local_datasource.dart';
import 'package:fitness_app/features/health_metrics/data/datasources/remote/health_metrics_remote_datasource.dart';
import 'package:fitness_app/features/health_metrics/data/repositories/health_metric_repository_impl.dart';
import 'package:fitness_app/features/health_metrics/data/services/google_fit_metrics_service.dart';
import 'package:fitness_app/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:fitness_app/features/health_metrics/domain/usecases/delete_health_metrics.dart';
import 'package:fitness_app/features/health_metrics/domain/usecases/get_health_metrics.dart';
import 'package:fitness_app/features/health_metrics/domain/usecases/save_health_metrics.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_bloc.dart';
import 'package:fitness_app/features/body_part_selection/presentation/bloc/body_part_selection_bloc.dart';
import 'package:fitness_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:fitness_app/features/notifications/data/datasources/local/notification_local_datasources.dart';
import 'package:fitness_app/features/notifications/data/models/notification_model.dart';
import 'package:fitness_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:fitness_app/features/notifications/domain/repositories/notifation_repository.dart';
import 'package:fitness_app/features/notifications/domain/usecases/clear_notification.dart';
import 'package:fitness_app/features/notifications/domain/usecases/get_notification.dart';
import 'package:fitness_app/features/notifications/domain/usecases/save_notification.dart';
import 'package:fitness_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/is_profile_completed.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/profile/data/datasources/local/profile_local_datasources.dart';
import 'package:fitness_app/features/profile/data/datasources/remote/profile_remote_datasources.dart';
import 'package:fitness_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:fitness_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:fitness_app/features/profile/domain/usecases/get_profile.dart';
import 'package:fitness_app/features/profile/domain/usecases/update_profile.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/streak/data/datasources/remote/streak_remote_datasources.dart';
import 'package:fitness_app/features/streak/data/repositories/streak_repository_impl.dart';
import 'package:fitness_app/features/streak/domain/repository/streak_repository.dart';
import 'package:fitness_app/features/streak/domain/usecases/get_streak.dart';
import 'package:fitness_app/features/streak/domain/usecases/update_streak.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/workout/data/datasources/remote/workout_remote_datasource.dart';
import 'package:fitness_app/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_workout_history.dart';
import 'package:fitness_app/features/workout/domain/usecases/save_workout_history.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_exercises.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fitness_app/features/onboarding/data/datasources/remote/onboarding_remote_data_source.dart';
import 'package:fitness_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:fitness_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:fitness_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in_as_guest.dart';
import 'package:fitness_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:fitness_app/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_out.dart';
import 'package:fitness_app/features/auth/domain/usecases/delete_account.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/save_user_profile.dart';

import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hive/hive.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External Registtrations

  final dietBox = await Hive.openBox('diet_box');
  final foodBox = await Hive.openBox('food_box');
  final healthMetricsBox = await Hive.openBox('health_metrics_box');
  final calculatorBox = await Hive.openBox('calculator_box');
  final profileBox = await Hive.openBox('profile_box');

  sl.registerLazySingleton<Box>(
    () => healthMetricsBox,
    instanceName: 'health_metrics_box',
  );

  sl.registerLazySingleton<Box>(() => dietBox, instanceName: 'diet_box');

  sl.registerLazySingleton<Box>(() => foodBox, instanceName: 'food_box');

  sl.registerLazySingleton<Box>(() => profileBox, instanceName: 'profile_box');

  sl.registerLazySingleton(() => const FlutterSecureStorage());

  sl.registerLazySingleton(() => FirebaseAuth.instance);

  sl.registerLazySingleton(
    () => GoogleSignIn(
      scopes: [
        'email',

        'https://www.googleapis.com/auth/fitness.activity.read',

        'https://www.googleapis.com/auth/fitness.body.read',
      ],
    ),
  );

  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Profile Registrations

  sl.registerLazySingleton<ProfileLocalDatasource>(
    () => ProfileLocalDatasourceImpl(sl<Box>(instanceName: 'profile_box')),
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

  // Notification Registrations

  /// HIVE BOX
  sl.registerLazySingleton(() => Hive.box<NotificationModel>('notifications'));

  /// LOCAL DATASOURCE
  sl.registerLazySingleton(
    () => NotificationLocalDatasource(notificationBox: sl()),
  );

  /// REPOSITORY
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(localDatasource: sl()),
  );

  /// USECASES
  sl.registerLazySingleton(() => SaveNotification(sl()));

  sl.registerLazySingleton(() => GetNotifications(sl()));

  sl.registerLazySingleton(() => ClearNotifications(sl()));

  /// BLOC
  sl.registerFactory(
    () => NotificationBloc(getNotifications: sl(), clearNotifications: sl()),
  );

  // Health Registrations

  sl.registerLazySingleton(() => GoogleFitService(googleSignIn: sl()));

  sl.registerLazySingleton<HealthRepository>(() => HealthRepositoryImpl(sl()));

  sl.registerFactory(() => HealthBloc(getHealthData: sl()));

  sl.registerLazySingleton(() => GetHealthData(sl()));

  // Onboarding Registtrations

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

  // Auth Registtrations

  sl.registerLazySingleton(
    () => AuthRemoteDataSource(firebaseAuth: sl(), googleSignIn: sl()),
  );

  sl.registerLazySingleton(() => AuthLocalDataSource(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
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
      getCurrentUser: sl(),
      watchAuthState: sl(),
      signOut: sl(),
      deleteAccount: sl(),
    ),
  );

  // home page registtrations

  sl.registerFactory(() => HomeBloc());

  // Ai Insights registtrations

  /// AI INSIGHTS

  sl.registerLazySingleton(() => AIInsightsRemoteDatasource());

  sl.registerLazySingleton<AIInsightsRepository>(
    () => AIInsightsRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GenerateAIInsights(sl()));

  sl.registerFactory(() => AIInsightsBloc(sl()));

  // body part selection registtrations

  sl.registerFactory(() => BodySelectionBloc());

  // Health Metrics Registrations

  sl.registerLazySingleton(() => GoogleFitMetricsService(googleSignIn: sl()));

  sl.registerLazySingleton<HealthMetricsLocalDataSource>(
    () => HealthMetricsLocalDataSourceImpl(
      sl<Box>(instanceName: 'health_metrics_box'),
    ),
  );

  sl.registerLazySingleton<HealthMetricsRemoteDataSource>(
    () => HealthMetricsRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<HealthMetricsRepository>(
    () => HealthMetricRepositoryImpl(sl(), sl(), sl(), sl()),
  );

  sl.registerLazySingleton(() => GetHealthMetrics(sl()));

  sl.registerLazySingleton(() => SaveHealthMetric(sl()));

  sl.registerLazySingleton(() => DeleteHealthMetric(sl()));

  sl.registerFactory(() => HealthMetricsBloc(sl(), sl(), sl()));

  // Diet Plan Registtrations

  sl.registerFactory(
    () => DietBloc(
      getDietPlans: sl(),
      saveDietPlan: sl(),
      deleteDietPlan: sl(),
      updateMealStatus: sl(),
      setActiveDietPlan: sl(),
      getDietHistory: sl(),
      saveDietHistory: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetDietPlans(sl()));
  sl.registerLazySingleton(() => SaveDietPlan(sl()));
  sl.registerLazySingleton(() => DeleteDietPlan(sl()));
  sl.registerLazySingleton(() => UpdateMealStatus(sl()));
  sl.registerLazySingleton(() => GetTodayMacros(sl()));
  sl.registerLazySingleton(() => SetActiveDietPlan(sl()));
  sl.registerLazySingleton(() => GetDietHistory(sl()));
  sl.registerLazySingleton(() => SaveDietHistory(sl()));

  sl.registerLazySingleton<DietRepository>(() => DietRepositoryImpl(sl()));

  sl.registerLazySingleton(
    () => DietRemoteDataSource(firestore: sl(), auth: sl()),
  );

  // Food Items Registrations

  sl.registerFactory(() => FoodItemsBloc(sl(), sl(), sl(), sl()));

  sl.registerLazySingleton(() => GetFoodItems(sl()));

  sl.registerLazySingleton(() => SaveFoodItem(sl()));

  sl.registerLazySingleton(() => DeleteFoodItemUseCase(sl()));

  sl.registerLazySingleton(() => UpdateFoodItemUseCase(sl()));

  sl.registerLazySingleton<FoodItemsRepository>(
    () => FoodItemsRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton(
    () => FoodItemLocalDataSource(sl<Box>(instanceName: 'food_box')),
  );

  sl.registerLazySingleton(
    () => FoodItemsRemoteDataSource(firestore: sl(), auth: sl()),
  );

  // Food Scanner Registrations

  sl.registerLazySingleton(() => FoodScannerRemoteDataSource());

  sl.registerLazySingleton<FoodScannerRepository>(
    () => FoodScannerRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => ScanBarcode(sl()));

  sl.registerFactory(() => FoodScannerBloc(sl()));

  // Workout Registrations

  sl.registerLazySingleton(
    () => WorkoutRemoteDatasource(firestore: sl(), auth: sl()),
  );

  sl.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetExercises(sl()));

  sl.registerLazySingleton(() => GetWorkoutHistory(sl()));

  sl.registerLazySingleton(() => SaveWorkoutHistory(sl()));

  sl.registerFactory(
    () => WorkoutBloc(
      getExercises: sl(),
      saveWorkoutHistory: sl(),
      getWorkoutHistory: sl(),
    ),
  );

  sl.registerLazySingleton<Box>(
    () => calculatorBox,
    instanceName: 'calculator_box',
  );

  /// Streak Registtrations

  sl.registerLazySingleton(
    () => StreakRemoteDatasource(firestore: sl(), auth: sl()),
  );

  sl.registerLazySingleton<StreakRepository>(
    () => StreakRepositoryImpl(remoteDatasource: sl()),
  );

  sl.registerLazySingleton(() => UpdateStreak(sl()));

  sl.registerLazySingleton(() => GetStreak(sl()));

  sl.registerFactory(() => StreakBloc(getStreak: sl(), updateStreak: sl()));

  /// LOCAL DATASOURCE

  sl.registerLazySingleton<HealthCalculatorLocalDatasource>(
    () => HealthCalculatorLocalDatasourceImpl(
      sl<Box>(instanceName: 'calculator_box'),
    ),
  );

  /// REPOSITORY

  sl.registerLazySingleton<HealthCalculatorRepository>(
    () => HealthCalculatorRepositoryImpl(sl()),
  );

  /// USECASES

  sl.registerLazySingleton(() => CalculateBMI(sl()));

  sl.registerLazySingleton(() => CalculateWaterIntake(sl()));

  sl.registerLazySingleton(() => CalculateProtein(sl()));

  sl.registerLazySingleton(() => CalculateCalories(sl()));

  /// BLOC

  sl.registerFactory(() => HealthCalculatorBloc(sl(), sl(), sl(), sl()));
}
