import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// The key product events. Blocs depend on this interface, not on Firebase,
/// so tests and previews can use [NoopAnalytics].
abstract interface class AppAnalytics {
  Future<void> setUserId(String? uid);
  Future<void> logLogin({required String method});
  Future<void> logWorkoutSaved({
    required String bodyPart,
    required int exerciseCount,
  });
  Future<void> logMealCompleted();
  Future<void> logDietPlanCompleted();
  Future<void> logFoodScanned({required bool found});
  Future<void> logWaterLogged({required int ml});
}

class NoopAnalytics implements AppAnalytics {
  const NoopAnalytics();

  @override
  Future<void> setUserId(String? uid) async {}
  @override
  Future<void> logLogin({required String method}) async {}
  @override
  Future<void> logWorkoutSaved({
    required String bodyPart,
    required int exerciseCount,
  }) async {}
  @override
  Future<void> logMealCompleted() async {}
  @override
  Future<void> logDietPlanCompleted() async {}
  @override
  Future<void> logFoodScanned({required bool found}) async {}
  @override
  Future<void> logWaterLogged({required int ml}) async {}
}

/// Firebase Analytics. Logging never throws: a failed analytics call must
/// not break the feature that triggered it.
class FirebaseAppAnalytics implements AppAnalytics {
  FirebaseAppAnalytics(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> _safe(Future<void> Function() log) async {
    try {
      await log();
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  @override
  Future<void> setUserId(String? uid) =>
      _safe(() => _analytics.setUserId(id: uid));

  @override
  Future<void> logLogin({required String method}) =>
      _safe(() => _analytics.logLogin(loginMethod: method));

  @override
  Future<void> logWorkoutSaved({
    required String bodyPart,
    required int exerciseCount,
  }) => _safe(
    () => _analytics.logEvent(
      name: 'workout_saved',
      parameters: {'body_part': bodyPart, 'exercise_count': exerciseCount},
    ),
  );

  @override
  Future<void> logMealCompleted() =>
      _safe(() => _analytics.logEvent(name: 'meal_completed'));

  @override
  Future<void> logDietPlanCompleted() =>
      _safe(() => _analytics.logEvent(name: 'diet_plan_completed'));

  @override
  Future<void> logFoodScanned({required bool found}) => _safe(
    () => _analytics.logEvent(
      name: 'food_scanned',
      parameters: {'found': found ? 1 : 0},
    ),
  );

  @override
  Future<void> logWaterLogged({required int ml}) => _safe(
    () => _analytics.logEvent(name: 'water_logged', parameters: {'ml': ml}),
  );
}
