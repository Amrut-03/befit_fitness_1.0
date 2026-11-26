import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/ai/gemma_on_device_llm.dart';
import 'package:fitness_app/core/ai/on_device_llm.dart';
import 'package:fitness_app/core/config/app_config.dart';
import 'package:fitness_app/core/di/storage_module.dart';
import 'package:fitness_app/core/l10n/locale_cubit.dart';
import 'package:fitness_app/core/services/reminder_sync.dart';
import 'package:fitness_app/core/health/health_platform_service.dart';
import 'package:fitness_app/core/health/health_plugin_service.dart';
import 'package:fitness_app/core/network/api_client.dart';
import 'package:fitness_app/core/session/session_notifier.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/is_profile_completed.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

/// Firebase, platform services and the session.
void registerCoreDependencies(GetIt sl) {
  sl.registerLazySingleton(() => ApiClient());

  sl.registerLazySingleton<AppAnalytics>(
    () => FirebaseAppAnalytics(FirebaseAnalytics.instance),
  );

  sl.registerLazySingleton(() => const FlutterSecureStorage());

  sl.registerLazySingleton(() => FirebaseAuth.instance);

  sl.registerLazySingleton(() => GoogleSignIn(scopes: ['email']));

  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Health Connect (Android) / HealthKit (iOS), shared by health features.
  sl.registerLazySingleton<HealthPlatformService>(
    () => HealthPluginService(
      sl<Box>(instanceName: StorageModule.healthPlatform),
    ),
  );

  // App language (device-level). Reminders are re-scheduled on change so
  // their text follows the new language.
  sl.registerLazySingleton(
    () => LocaleCubit(
      sl<Box>(instanceName: StorageModule.appSettings),
      onChanged: () => sl<ReminderSync>().reapply(),
    ),
  );

  // On-device Gemma, shared by AI insights and the coach. Device-level: the
  // model survives logout.
  sl.registerLazySingleton<OnDeviceLlm>(
    () => GemmaOnDeviceLlm(modelUrl: AppConfig.onDeviceModelUrl),
  );

  // Session (auth + profile state for the router and user scope)
  sl.registerLazySingleton(
    () => SessionNotifier(
      uidChanges: sl<FirebaseAuth>().authStateChanges().map((u) => u?.uid),
      isProfileCompleted: sl<IsProfileCompleted>().call,
    ),
  );
}
