import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/session/session_notifier.dart';

/// Pure redirect logic for the router, kept separate so it's unit-testable.
/// Returns the location to redirect to, or null to stay.
class SessionRedirect {
  SessionRedirect._();

  static const splash = Routes.splash;
  static const intro = Routes.intro;
  static const login = Routes.login;
  static const home = Routes.home;
  static const firstOnboardingStep = Routes.goalSelection;

  static const onboardingSteps = {
    Routes.goalSelection,
    Routes.genderSelection,
    Routes.bodyMetrics,
    Routes.activityLevel,
  };

  static String? resolve(SessionStatus status, String location) {
    switch (status) {
      case SessionStatus.unknown:
      case SessionStatus.error:
        // The splash screen shows a loader, or a retry button on error.
        return location == splash ? null : splash;

      case SessionStatus.signedOut:
        if (location == splash) return intro;
        if (location == intro || location == login) return null;
        return login;

      case SessionStatus.needsProfile:
        return onboardingSteps.contains(location) ? null : firstOnboardingStep;

      case SessionStatus.ready:
        if (location == splash ||
            location == intro ||
            location == login ||
            onboardingSteps.contains(location)) {
          return home;
        }
        return null;
    }
  }
}
