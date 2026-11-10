import 'dart:io';

import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/di/storage_module.dart';
import 'package:fitness_app/core/session/session_notifier.dart';
import 'package:fitness_app/features/ai_insights/presentation/bloc/ai_insights_bloc.dart';
import 'package:fitness_app/features/auth/data/datasources/local/user_data_local_datasource.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_bloc.dart';
import 'package:fitness_app/features/food_scanner/presentation/bloc/food_scanner_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health_calculator/presentation/bloc/health_calculator_bloc.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_bloc.dart';
import 'package:fitness_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:fitness_app/features/notifications/data/models/notification_model.dart';
import 'package:fitness_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hive_di');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }
    await Hive.openBox<NotificationModel>(StorageModule.notifications);
  });

  tearDown(() async {
    await sl.reset();
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('init() registers every feature without duplicates', () async {
    await init(); // get_it throws on duplicate registrations

    for (final registered in [
      sl.isRegistered<AuthBloc>(),
      sl.isRegistered<OnboardingProfileBloc>(),
      sl.isRegistered<ProfileBloc>(),
      sl.isRegistered<HomeBloc>(),
      sl.isRegistered<HealthBloc>(),
      sl.isRegistered<HealthMetricsBloc>(),
      sl.isRegistered<HealthCalculatorBloc>(),
      sl.isRegistered<AIInsightsBloc>(),
      sl.isRegistered<StreakBloc>(),
      sl.isRegistered<DietBloc>(),
      sl.isRegistered<FoodItemsBloc>(),
      sl.isRegistered<FoodScannerBloc>(),
      sl.isRegistered<WorkoutBloc>(),
      sl.isRegistered<NotificationBloc>(),
      sl.isRegistered<SessionNotifier>(),
    ]) {
      expect(registered, isTrue);
    }

    // Every user-scoped box is wired into the logout/deletion wipe.
    expect(
      sl<UserDataLocalDataSource>().boxes,
      hasLength(StorageModule.userScoped.length + 1),
    );
  });
}
