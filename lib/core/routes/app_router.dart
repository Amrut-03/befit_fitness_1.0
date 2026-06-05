import 'package:fitness_app/features/diet/presentation/pages/diet_history_page.dart';
import 'package:fitness_app/features/diet/presentation/pages/diet_planing_page.dart';
import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:fitness_app/features/food_item/presentation/pages/food_item_page.dart';
import 'package:fitness_app/features/food_item/presentation/pages/manual_food_entry_page.dart';
import 'package:fitness_app/features/food_scanner/presentation/pages/barcode_scanner_page.dart';
import 'package:fitness_app/features/health_calculator/presentation/pages/health_calculator_list_page.dart';
import 'package:fitness_app/features/health_calculator/presentation/pages/health_calculator_page.dart';
import 'package:fitness_app/features/home/presentation/pages/home_page.dart';
import 'package:fitness_app/features/notifications/presentation/pages/notification_page.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/activity_level_page.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/body_metrics_page.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/gender_selection.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/goal_selection_page.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:fitness_app/features/profile/presentation/pages/history_screen.dart';
import 'package:fitness_app/features/profile/presentation/pages/notification_page.dart';
import 'package:fitness_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:fitness_app/features/workout/presentation/pages/workout_history_page.dart';
import 'package:fitness_app/features/workout/presentation/pages/workout_list_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_app/features/startup/presentation/pages/startup_page.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fitness_app/features/auth/presentation/pages/login_page.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/presentation/pages/diet_list_page.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const StartupPage()),

      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      GoRoute(path: '/home', builder: (context, state) => const HomePage()),

      GoRoute(
        path: '/profile',
        builder: (context, state) {
          return const ProfilePage();
        },
      ),

      GoRoute(
        path: '/diet-list',
        builder: (context, state) {
          return const DietListPage();
        },
      ),

      GoRoute(
        path: '/plan-diet',
        builder: (context, state) {
          final plan = state.extra as DietPlanEntity?;
          return BlocProvider.value(
            value: context.read<DietBloc>(),
            child: PlanDietPage(existingPlan: plan),
          );
        },
      ),

      GoRoute(
        path: '/health-calculator',

        builder: (context, state) {
          final type = state.extra as String;

          return HealthCalculatorPage(type: type);
        },
      ),

      GoRoute(
        path: '/health-calculators',
        builder: (context, state) {
          return const HealthCalculatorListPage();
        },
      ),

      GoRoute(
        path: "/history",
        builder: (context, state) => const HistoryPage(),
      ),

      GoRoute(
        path: "/workout-history",
        builder: (context, state) => const WorkoutHistoryPage(),
      ),

      GoRoute(
        path: "/diet-history",
        builder: (context, state) => const DietHistoryPage(),
      ),

      GoRoute(
        path: '/food-items',
        builder: (context, state) => const FoodItemsPage(),
      ),

      GoRoute(
        path: '/manual-food-entry',
        builder: (context, state) {
          return ManualFoodEntryPage(item: state.extra as FoodItemEntity?);
        },
      ),

      GoRoute(
        path: "/barcode-food-entry",
        builder: (context, state) => const BarcodeScannerPage(),
      ),

      GoRoute(
        path: '/workout',
        builder: (context, state) {
          final bodyPart = state.extra as String?;
          return WorkoutListPage(bodyPart: bodyPart);
        },
      ),

      GoRoute(
        path: '/goal-selection',
        builder: (_, __) => const GoalSelectionPage(),
      ),

      GoRoute(
        path: '/gender-selection',
        builder: (_, __) => const GenderSelectionPage(),
      ),

      GoRoute(
        path: '/body-metrics',
        builder: (_, __) => const BodyMetricsPage(),
      ),

      GoRoute(
        path: '/activity-level',
        builder: (_, __) => const ActivityLevelPage(),
      ),

      GoRoute(
        path: '/edit-profile',

        builder: (context, state) {
          final profile = state.extra as ProfileEntity;
          return EditProfilePage(profile: profile);
        },
      ),

      GoRoute(
        path: '/notification-setting-page',
        builder: (context, state) => const NotificationSettingPage(),
      ),

      GoRoute(
        path: '/notification-page',
        builder: (context, state) => const NotificationPage(),
      ),
    ],
  );
}
