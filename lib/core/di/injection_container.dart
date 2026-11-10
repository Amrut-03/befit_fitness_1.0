import 'package:fitness_app/core/di/core_module.dart';
import 'package:fitness_app/core/di/storage_module.dart';
import 'package:fitness_app/features/ai_insights/ai_insights_injection.dart';
import 'package:fitness_app/features/auth/auth_injection.dart';
import 'package:fitness_app/features/body_part_selection/body_part_selection_injection.dart';
import 'package:fitness_app/features/diet/diet_injection.dart';
import 'package:fitness_app/features/food_item/food_item_injection.dart';
import 'package:fitness_app/features/food_scanner/food_scanner_injection.dart';
import 'package:fitness_app/features/health/health_injection.dart';
import 'package:fitness_app/features/health_calculator/health_calculator_injection.dart';
import 'package:fitness_app/features/health_metrics/health_metrics_injection.dart';
import 'package:fitness_app/features/home/home_injection.dart';
import 'package:fitness_app/features/notifications/notifications_injection.dart';
import 'package:fitness_app/features/onboarding/onboarding_injection.dart';
import 'package:fitness_app/features/profile/profile_injection.dart';
import 'package:fitness_app/features/progress_report/progress_report_injection.dart';
import 'package:fitness_app/features/streak/streak_injection.dart';
import 'package:fitness_app/features/water_intake/water_intake_injection.dart';
import 'package:fitness_app/features/workout/workout_injection.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

/// Registers all dependencies. Each feature owns its registrations in
/// `features/<feature>/<feature>_injection.dart`.
Future<void> init() async {
  await StorageModule.register(sl);

  registerCoreDependencies(sl);
  registerAuthDependencies(sl);
  registerOnboardingDependencies(sl);
  registerProfileDependencies(sl);
  registerHomeDependencies(sl);
  registerHealthDependencies(sl);
  registerHealthMetricsDependencies(sl);
  registerHealthCalculatorDependencies(sl);
  registerAiInsightsDependencies(sl);
  registerStreakDependencies(sl);
  registerDietDependencies(sl);
  registerFoodItemDependencies(sl);
  registerFoodScannerDependencies(sl);
  registerWorkoutDependencies(sl);
  registerBodyPartSelectionDependencies(sl);
  registerNotificationsDependencies(sl);
  registerWaterIntakeDependencies(sl);
  registerProgressReportDependencies(sl);
}
