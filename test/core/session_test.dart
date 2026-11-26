import 'dart:async';

import 'package:fitness_app/core/routes/session_redirect.dart';
import 'package:fitness_app/core/session/session_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionRedirect.resolve', () {
    String? r(SessionStatus s, String loc) => SessionRedirect.resolve(s, loc);

    test('unknown/error: everything goes to the splash', () {
      for (final s in [SessionStatus.unknown, SessionStatus.error]) {
        expect(r(s, '/'), isNull);
        expect(r(s, '/home'), '/');
        expect(r(s, '/login'), '/');
      }
    });

    test('signed out: splash → intro; protected → login', () {
      expect(r(SessionStatus.signedOut, '/'), '/onboarding');
      expect(r(SessionStatus.signedOut, '/onboarding'), isNull);
      expect(r(SessionStatus.signedOut, '/login'), isNull);
      expect(r(SessionStatus.signedOut, '/home'), '/login');
      expect(r(SessionStatus.signedOut, '/goal-selection'), '/login');
    });

    test('needs profile: only onboarding steps allowed', () {
      expect(r(SessionStatus.needsProfile, '/login'), '/goal-selection');
      expect(r(SessionStatus.needsProfile, '/home'), '/goal-selection');
      for (final step in SessionRedirect.onboardingSteps) {
        expect(r(SessionStatus.needsProfile, step), isNull);
      }
    });

    test('ready: splash/login/onboarding → home; app pages allowed', () {
      for (final loc in ['/', '/login', '/onboarding', '/activity-level']) {
        expect(r(SessionStatus.ready, loc), '/home');
      }
      expect(r(SessionStatus.ready, '/home'), isNull);
      expect(r(SessionStatus.ready, '/profile'), isNull);
    });
  });

  group('SessionNotifier', () {
    late StreamController<String?> uids;
    setUp(() => uids = StreamController<String?>());
    tearDown(() => uids.close());

    Future<void> pump() => Future<void>.delayed(Duration.zero);

    test('signed out', () async {
      final s = SessionNotifier(
        uidChanges: uids.stream,
        isProfileCompleted: () async => true,
      );
      expect(s.status, SessionStatus.unknown);
      uids.add(null);
      await pump();
      expect(s.status, SessionStatus.signedOut);
      expect(s.uid, isNull);
    });

    test(
      'signed in: checks the profile once, then ready / needsProfile',
      () async {
        var calls = 0;
        const completed = false;
        final s = SessionNotifier(
          uidChanges: uids.stream,
          isProfileCompleted: () async {
            calls++;
            return completed;
          },
        );
        uids.add('alice');
        await pump();
        expect(s.status, SessionStatus.needsProfile);
        expect(s.uid, 'alice');

        s.markProfileCompleted();
        expect(s.status, SessionStatus.ready);

        // A duplicate auth event for the same user doesn't re-query.
        uids.add('alice');
        await pump();
        expect(calls, 1);
      },
    );

    test('profile check failure → error, retry recovers', () async {
      var fail = true;
      final s = SessionNotifier(
        uidChanges: uids.stream,
        isProfileCompleted: () async {
          if (fail) throw Exception('offline');
          return true;
        },
      );
      uids.add('alice');
      await pump();
      expect(s.status, SessionStatus.error);

      fail = false;
      await s.retry();
      expect(s.status, SessionStatus.ready);
    });

    test('a stale profile check from a previous user is ignored', () async {
      final aliceCheck = Completer<bool>();
      final s = SessionNotifier(
        uidChanges: uids.stream,
        isProfileCompleted: () => aliceCheck.future,
      );
      uids.add('alice');
      await pump();
      uids.add(null);
      await pump();
      aliceCheck.complete(true);
      await pump();
      expect(s.status, SessionStatus.signedOut);
    });
  });
}
