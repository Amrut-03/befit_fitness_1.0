import 'package:fitness_app/core/observability/observability.dart';
import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/routes/app_router.dart';
import 'package:fitness_app/core/services/notification_service.dart';
import 'package:fitness_app/core/services/reminder_sync.dart';
import 'package:fitness_app/core/session/session_notifier.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/features/ai_insights/presentation/bloc/ai_insights_bloc.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_event.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_bloc.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_event.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_event.dart';
import 'package:fitness_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:fitness_app/features/notifications/data/models/notification_model.dart';
import 'package:fitness_app/features/notifications/domain/usecases/save_notification.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_event.dart';
import 'package:fitness_app/features/progress_report/presentation/bloc/weekly_report_bloc.dart';
import 'package:fitness_app/features/water_intake/presentation/bloc/water_intake_bloc.dart';
import 'package:fitness_app/features/workout/presentation/cubit/workout_session_cubit.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:fitness_app/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setUpCrashReporting();

  // App Check attests that requests to Firestore and Firebase AI Logic come
  // from this genuine app. Debug builds use the debug provider: copy the token
  // it logs ("Enter this debug secret into the allow list...") into
  // Firebase Console → App Check → Apps → Manage debug tokens.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kReleaseMode
        ? const AndroidPlayIntegrityProvider()
        : const AndroidDebugProvider(),
    providerApple: kReleaseMode
        ? const AppleAppAttestWithDeviceCheckFallbackProvider()
        : const AppleDebugProvider(),
  );

  await Hive.initFlutter();

  Hive.registerAdapter(NotificationModelAdapter());

  await Hive.openBox<NotificationModel>('notifications');
  await init();

  // FCM: background/terminated messages are stored for the in-app list.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.instance.initialize(
    saveNotification: sl<SaveNotification>().call,
  );
  sl<ReminderSync>().start();
  syncObservabilityUser(sl<SessionNotifier>(), sl<AppAnalytics>());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            routerConfig: AppRouter.router,
            builder: (context, child) => UserScope(child: child!),
          ),
        );
      },
    );
  }
}

/// Provides the blocs that hold per-user data.
///
/// The provider tree is keyed by the signed-in uid, so on logout, account
/// deletion or a user switch every one of these blocs is closed (cancelling
/// its Firestore streams) and recreated empty for the next user. Providers
/// are lazy, so nothing loads until a page reads the bloc, which means no
/// network calls fire before anyone is signed in.
///
/// Only blocs shared across several routes live here. Page-local blocs
/// (food scanner, body selection) are provided by their route or widget.
class UserScope extends StatelessWidget {
  const UserScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final session = sl<SessionNotifier>();

    return ListenableBuilder(
      listenable: session,
      builder: (context, _) => MultiBlocProvider(
        key: ValueKey(session.uid),
        providers: [
          BlocProvider(create: (_) => sl<OnboardingProfileBloc>()),
          BlocProvider(create: (_) => sl<AIInsightsBloc>()),
          BlocProvider(create: (_) => sl<HomeBloc>()..add(LoadHomeDashboard())),
          BlocProvider(
            create: (_) => sl<ProfileBloc>()..add(LoadProfileEvent()),
          ),
          BlocProvider(create: (_) => sl<DietBloc>()..add(LoadDietPlans())),
          BlocProvider(create: (_) => sl<HealthBloc>()..add(LoadHealthData())),
          BlocProvider(
            create: (_) => sl<FoodItemsBloc>()..add(const LoadFoodItems()),
          ),
          BlocProvider(create: (_) => sl<StreakBloc>()..add(LoadStreakEvent())),
          // Lazy: starts when Home's water card or the Water page reads it.
          BlocProvider(create: (_) => sl<WaterIntakeBloc>()),
          BlocProvider(
            create: (_) => sl<WorkoutBloc>()..add(const LoadExercisesEvent()),
          ),
          // Shared by Home (resume bar), the exercise list and the session.
          BlocProvider(create: (_) => sl<WorkoutSessionCubit>()),
          // Home's weekly progress card (the report page has its own).
          BlocProvider(create: (_) => sl<WeeklyReportBloc>()),
        ],
        child: child,
      ),
    );
  }
}
