import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:fitness_app/core/session/session_notifier.dart';
import 'package:flutter/foundation.dart';

/// Routes uncaught errors to Crashlytics and turns collection off in debug
/// builds, so local development doesn't pollute the dashboards.
Future<void> setUpCrashReporting() async {
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);

  // Errors inside the Flutter framework (build, layout, paint).
  FlutterError.onError = crashlytics.recordFlutterFatalError;

  // Uncaught async errors outside the framework.
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(crashlytics.recordError(error, stack, fatal: true));
    return true;
  };
}

/// Tags crash reports and analytics with the signed-in uid (never email or
/// name), and clears it on sign-out.
void syncObservabilityUser(SessionNotifier session, AppAnalytics analytics) {
  String? last;
  void apply() {
    final uid = session.uid;
    if (uid == last) return;
    last = uid;
    unawaited(FirebaseCrashlytics.instance.setUserIdentifier(uid ?? ''));
    unawaited(analytics.setUserId(uid));
  }

  session.addListener(apply);
  apply();
}
