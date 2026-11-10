import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/network/api_client.dart';
import 'package:fitness_app/core/session/session_notifier.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/is_profile_completed.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  // Session (auth + profile state for the router and user scope)
  sl.registerLazySingleton(
    () => SessionNotifier(
      uidChanges: sl<FirebaseAuth>().authStateChanges().map((u) => u?.uid),
      isProfileCompleted: sl<IsProfileCompleted>().call,
    ),
  );
}
