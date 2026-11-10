import 'dart:async';

import 'package:fitness_app/core/routes/routes.dart';
import 'package:fitness_app/core/routes/session_redirect.dart';
import 'package:fitness_app/core/session/session_notifier.dart';
import 'package:fitness_app/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/is_profile_completed.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/save_user_profile.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/activity_level_page.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/body_metrics_page.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/gender_selection.dart';
import 'package:fitness_app/features/onboarding/presentation/pages/goal_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'a11y.dart';
import 'pump_app.dart';

class _Save extends Mock implements SaveUserProfile {}

class _Get extends Mock implements GetUserProfile {}

class _IsCompleted extends Mock implements IsProfileCompleted {}

/// Drives the real onboarding pages, bloc and session redirect from the
/// first step to Home. Only the Firestore write is mocked.
void main() {
  late StreamController<String?> uid;
  late SessionNotifier session;

  setUpAll(
    () => registerFallbackValue(
      const UserProfileEntity(
        goal: '',
        gender: '',
        weight: 0,
        height: 0,
        age: 0,
        activityLevel: '',
        profileCompleted: false,
        dailyStepGoal: 0,
        dailyCalorieGoal: 0,
        proteinGoal: 0,
        carbsGoal: 0,
        fatGoal: 0,
        email: '',
      ),
    ),
  );

  // Created inside the test body: streams made in setUp live outside the
  // widget test's fake-async zone and never deliver during pump().
  void startSession() {
    uid = StreamController<String?>();
    session = SessionNotifier(
      uidChanges: uid.stream,
      isProfileCompleted: () async => false,
    );
    GetIt.instance.registerSingleton<SessionNotifier>(session);
    addTearDown(() async {
      await GetIt.instance.reset();
      await uid.close();
    });
  }

  GoRouter buildRouter() => GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: session,
    redirect: (_, state) =>
        SessionRedirect.resolve(session.status, state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SizedBox()),
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
        path: Routes.home,
        builder: (_, _) => const Scaffold(body: Text('HOME')),
      ),
    ],
  );

  Future<void> tapAndSettle(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  for (final large in [false, true]) {
    testWidgets('new user goes goal → gender → metrics → activity → home'
        '${large ? ' (largest text)' : ''}', (tester) async {
      if (large) useLargestText(tester);
      final semantics = tester.ensureSemantics();
      startSession();
      final save = _Save();
      when(() => save(any())).thenAnswer((_) async {});
      final bloc = OnboardingProfileBloc(
        saveUserProfile: save,
        getUserProfile: _Get(),
        isProfileCompleted: _IsCompleted(),
      );
      addTearDown(bloc.close);

      await tester.pumpRouterApp(
        buildRouter(),
        wrap: (child) => BlocProvider.value(value: bloc, child: child),
      );

      // Signed in without a profile → the session sends us to onboarding.
      uid.add('u1');
      await tester.pumpAndSettle();
      expect(find.byType(GoalSelectionPage), findsOneWidget);
      if (!large) {
        await expectAccessible(tester, semantics);
      } else {
        semantics.dispose();
      }

      await tapAndSettle(tester, 'Build Muscle');
      await tapAndSettle(tester, 'Continue');
      expect(find.byType(GenderSelectionPage), findsOneWidget);

      await tapAndSettle(tester, 'Female');
      await tapAndSettle(tester, 'Continue');
      expect(find.byType(BodyMetricsPage), findsOneWidget);

      await tapAndSettle(tester, 'Continue');
      expect(find.byType(ActivityLevelPage), findsOneWidget);

      await tapAndSettle(tester, 'Active');
      await tapAndSettle(tester, 'Continue');

      expect(find.text('HOME'), findsOneWidget);
      expect(session.status, SessionStatus.ready);

      final saved =
          verify(() => save(captureAny())).captured.single as UserProfileEntity;
      expect(saved.goal, 'Build Muscle');
      expect(saved.gender, 'Female');
      expect(saved.activityLevel, 'Active');
      expect(saved.profileCompleted, isTrue);
      expect(saved.dailyCalorieGoal, greaterThan(0));
    });
  }
}
