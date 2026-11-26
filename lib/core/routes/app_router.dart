import 'package:fitness_app/features/ai_coach/presentation/pages/coach_page.dart';
import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/routes/session_redirect.dart';
import 'package:fitness_app/core/session/session_notifier.dart';
import 'package:fitness_app/features/progress_report/presentation/bloc/weekly_report_bloc.dart';
import 'package:fitness_app/features/progress_report/presentation/pages/weekly_report_page.dart';
import 'package:fitness_app/features/water_intake/presentation/pages/water_intake_page.dart';
import 'package:fitness_app/features/auth/presentation/pages/login_page.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/pages/diet_history_page.dart';
import 'package:fitness_app/features/diet/presentation/pages/diet_list_page.dart';
import 'package:fitness_app/features/diet/presentation/pages/diet_planning_page.dart';
import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';
import 'package:fitness_app/features/food_item/presentation/pages/food_item_page.dart';
import 'package:fitness_app/features/food_item/presentation/pages/manual_food_entry_page.dart';
import 'package:fitness_app/features/food_scanner/presentation/bloc/food_scanner_bloc.dart';
import 'package:fitness_app/features/food_scanner/presentation/pages/barcode_scanner_page.dart';
import 'package:fitness_app/features/health_calculator/presentation/pages/health_calculator_list_page.dart';
import 'package:fitness_app/features/health_calculator/presentation/pages/health_calculator_page.dart';
import 'package:fitness_app/features/home/presentation/pages/home_page.dart';
import 'package:fitness_app/features/notifications/presentation/pages/notification_page.dart';
import 'package:fitness_app/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/activity_level_page.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/body_metrics_page.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/gender_selection.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/goal_selection_page.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:fitness_app/features/profile/presentation/pages/history_screen.dart';
import 'package:fitness_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:fitness_app/features/startup/presentation/pages/startup_page.dart';
import 'package:fitness_app/features/workout/presentation/pages/workout_history_page.dart';
import 'package:fitness_app/features/workout/presentation/pages/workout_session_page.dart';
import 'package:fitness_app/features/workout/presentation/pages/workout_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static SessionNotifier get _session => sl<SessionNotifier>();

  static final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: _session,
    redirect: (context, state) =>
        SessionRedirect.resolve(_session.status, state.matchedLocation),
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const StartupPage(),
      ),

      GoRoute(
        path: Routes.intro,
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(path: Routes.home, builder: (context, state) => const HomePage()),

      GoRoute(
        path: Routes.weeklyReport,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              sl<WeeklyReportBloc>()..add(const WeeklyReportRequested()),
          child: const WeeklyReportPage(),
        ),
      ),

      GoRoute(
        path: Routes.coach,
        builder: (context, state) => const CoachPage(),
      ),

      GoRoute(
        path: Routes.water,
        builder: (context, state) => const WaterIntakePage(),
      ),

      GoRoute(
        path: Routes.profile,
        builder: (context, state) {
          return const ProfilePage();
        },
      ),

      GoRoute(
        path: Routes.dietList,
        builder: (context, state) {
          return const DietListPage();
        },
      ),

      GoRoute(
        path: Routes.planDiet,
        builder: (context, state) {
          final plan = _extra<DietPlanEntity>(state);
          return BlocProvider.value(
            value: context.read<DietBloc>(),
            child: PlanDietPage(existingPlan: plan),
          );
        },
      ),

      GoRoute(
        path: Routes.healthCalculatorPath,
        redirect: (context, state) => state.uri.queryParameters['type'] == null
            ? Routes.healthCalculators
            : null,
        builder: (context, state) =>
            HealthCalculatorPage(type: state.uri.queryParameters['type']!),
      ),

      GoRoute(
        path: Routes.healthCalculators,
        builder: (context, state) {
          return const HealthCalculatorListPage();
        },
      ),

      GoRoute(
        path: Routes.history,
        builder: (context, state) => const HistoryPage(),
      ),

      GoRoute(
        path: Routes.workoutHistory,
        builder: (context, state) => const WorkoutHistoryPage(),
      ),

      GoRoute(
        path: Routes.dietHistory,
        builder: (context, state) => const DietHistoryPage(),
      ),

      GoRoute(
        path: Routes.foodItems,
        builder: (context, state) => const FoodItemsPage(),
      ),

      GoRoute(
        path: Routes.manualFoodEntry,
        builder: (context, state) {
          return ManualFoodEntryPage(item: _extra<FoodItemEntity>(state));
        },
      ),

      GoRoute(
        path: Routes.barcodeScanner,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<FoodScannerBloc>(),
          child: const BarcodeScannerPage(),
        ),
      ),

      GoRoute(
        path: Routes.workoutSession,
        builder: (context, state) => const WorkoutSessionPage(),
      ),

      GoRoute(
        path: Routes.workout,
        builder: (context, state) {
          final bodyPart = _extra<String>(state);
          return WorkoutListPage(bodyPart: bodyPart);
        },
      ),

      GoRoute(
        path: Routes.goalSelection,
        builder: (_, _) => const GoalSelectionPage(),
      ),

      GoRoute(
        path: Routes.genderSelection,
        builder: (_, _) => const GenderSelectionPage(),
      ),

      GoRoute(
        path: Routes.bodyMetrics,
        builder: (_, _) => const BodyMetricsPage(),
      ),

      GoRoute(
        path: Routes.activityLevel,
        builder: (_, _) => const ActivityLevelPage(),
      ),

      GoRoute(
        path: Routes.editProfile,
        // The profile is passed in memory; on a deep link or restored state
        // there's nothing to edit, so go back to the profile screen.
        redirect: (context, state) =>
            state.extra is ProfileEntity ? null : Routes.profile,
        builder: (context, state) =>
            EditProfilePage(profile: state.extra! as ProfileEntity),
      ),

      GoRoute(
        path: Routes.notificationSettings,
        builder: (context, state) => const NotificationSettingsPage(),
      ),

      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationPage(),
      ),
    ],
  );

  /// `state.extra` as [T], or null if it's missing or another type. A plain
  /// `as` cast crashes on deep links and restored state, where extra is null
  /// or a decoded JSON value.
  static T? _extra<T>(GoRouterState state) {
    final extra = state.extra;
    return extra is T ? extra : null;
  }
}
