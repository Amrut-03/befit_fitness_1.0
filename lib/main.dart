import 'package:firebase_core/firebase_core.dart';
import 'package:fitness_app/features/ai_insights/presentation/bloc/ai_insights_bloc.dart';
import 'package:fitness_app/features/body_part_selection/presentation/bloc/body_part_selection_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_event.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_bloc.dart';
import 'package:fitness_app/features/food_item/presentation/bloc/food_item_event.dart';
import 'package:fitness_app/features/food_scanner/presentation/bloc/food_scanner_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_event.dart';
import 'package:fitness_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:fitness_app/core/di/injection_container.dart';
import 'package:fitness_app/core/routes/app_router.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/notifications/data/models/notification_model.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_event.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Hive.initFlutter();

  Hive.registerAdapter(NotificationModelAdapter());

  await Hive.openBox<NotificationModel>('notifications');

  await init();

  // final token =
  //   await FirebaseMessaging
  //       .instance
  //       .getToken();

  // print(
  //   "FCM TOKEN: $token",
  // );

  // final settings =
  //   await FirebaseMessaging.instance
  //       .requestPermission();

  // print(
  //   'Permission: ${settings.authorizationStatus}',
  // );

  // FirebaseMessaging.onMessage.listen(
  //   (message) {

  //     print(
  //       'MESSAGE RECEIVED: ${message.notification?.title}',
  //     );

  //     print(
  //       'BODY: ${message.notification?.body}',
  //     );
  //   },
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<OnboardingProfileBloc>()),
            BlocProvider(create: (_) => sl<AIInsightsBloc>()),
            BlocProvider(create: (_) => sl<AuthBloc>()),
            BlocProvider(
              create: (_) => sl<HomeBloc>()..add(LoadHomeDashboard()),
            ),
            BlocProvider(create: (_) => sl<AIInsightsBloc>()),
            BlocProvider(
              create: (_) => sl<ProfileBloc>()..add(LoadProfileEvent()),
            ),
            BlocProvider(create: (_) => sl<BodySelectionBloc>()),
            BlocProvider(create: (_) => sl<DietBloc>()..add(LoadDietPlans())),
            BlocProvider(
              create: (_) => sl<HealthBloc>()..add(LoadHealthData()),
            ),
            BlocProvider(
              create: (_) => sl<FoodItemsBloc>()..add(LoadFoodItems()),
            ),
            BlocProvider(create: (_) => sl<FoodScannerBloc>()),
            BlocProvider(
              create: (_) => sl<StreakBloc>()..add(LoadStreakEvent()),
            ),
            BlocProvider(
              create: (_) => sl<WorkoutBloc>()..add(LoadExercisesEvent()),
            ),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
