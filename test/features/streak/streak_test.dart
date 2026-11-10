import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/streak/data/datasources/remote/streak_remote_datasources.dart';
import 'package:fitness_app/features/streak/domain/utils/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

class _User extends Fake implements User {
  @override
  String get uid => 'alice';
}

class _Auth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => _User();
}

void main() {
  group('StreakCalculator.next', () {
    int? next(int current, DateTime? last, DateTime now) =>
        StreakCalculator.next(current: current, lastActive: last, now: now);

    test('first activity starts at 1', () {
      expect(next(0, null, DateTime(2026, 11, 10, 9)), 1);
    });

    test('same day → no change', () {
      expect(
        next(4, DateTime(2026, 11, 10, 0, 5), DateTime(2026, 11, 10, 23, 55)),
        isNull,
      );
    });

    test('next day → +1', () {
      expect(next(4, DateTime(2026, 11, 9, 9), DateTime(2026, 11, 10, 20)), 5);
    });

    test('late night → early morning (<24h) still counts as next day', () {
      expect(next(4, DateTime(2026, 11, 9, 23), DateTime(2026, 11, 10, 8)), 5);
    });

    test('nearly 48h but only one calendar day apart → +1', () {
      expect(
        next(4, DateTime(2026, 11, 9, 0, 1), DateTime(2026, 11, 10, 23, 59)),
        5,
      );
    });

    test('gap of 2+ days → reset to 1', () {
      expect(next(9, DateTime(2026, 11, 7, 12), DateTime(2026, 11, 10, 12)), 1);
      expect(next(9, DateTime(2026, 11, 8, 23), DateTime(2026, 11, 10, 1)), 1);
    });

    test('month and year boundaries', () {
      expect(next(2, DateTime(2026, 11, 30, 22), DateTime(2026, 12, 1, 7)), 3);
      expect(next(2, DateTime(2026, 12, 31, 22), DateTime(2027, 1, 1, 7)), 3);
    });

    test('DST transition days count as 1 day', () {
      // Calendar arithmetic is done in UTC dates, so 23h/25h days are fine.
      expect(
        StreakCalculator.calendarDaysBetween(
          DateTime(2026, 3, 8, 12),
          DateTime(2026, 3, 9, 12),
        ),
        1,
      );
      expect(
        StreakCalculator.calendarDaysBetween(
          DateTime(2026, 11, 1, 12),
          DateTime(2026, 11, 2, 12),
        ),
        1,
      );
    });
  });

  group('StreakCalculator.effective', () {
    final now = DateTime(2026, 11, 10, 9);
    test('shows the stored streak if active today or yesterday', () {
      expect(
        StreakCalculator.effective(
          stored: 5,
          lastActive: DateTime(2026, 11, 10, 1),
          now: now,
        ),
        5,
      );
      expect(
        StreakCalculator.effective(
          stored: 5,
          lastActive: DateTime(2026, 11, 9, 23),
          now: now,
        ),
        5,
      );
    });
    test('a broken streak shows 0', () {
      expect(
        StreakCalculator.effective(
          stored: 5,
          lastActive: DateTime(2026, 11, 8, 23),
          now: now,
        ),
        0,
      );
      expect(
        StreakCalculator.effective(stored: 5, lastActive: null, now: now),
        0,
      );
    });
  });

  group('StreakRemoteDatasource.updateStreak', () {
    late FakeFirebaseFirestore firestore;
    late StreakRemoteDatasource ds;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      ds = StreakRemoteDatasource(firestore: firestore, auth: _Auth());
    });

    Future<Map<String, dynamic>> user() async =>
        (await firestore.doc('users/alice').get()).data()!;

    test('creates the doc if missing (no update() crash)', () async {
      await ds.updateStreak(now: DateTime(2026, 11, 10, 9));
      expect((await user())['streak'], 1);
    });

    test(
      'increments across midnight and ignores repeats the same day',
      () async {
        await firestore.doc('users/alice').set({
          'name': 'Alice',
          'streak': 3,
          'lastActiveDate': Timestamp.fromDate(DateTime(2026, 11, 9, 23)),
        });

        await ds.updateStreak(now: DateTime(2026, 11, 10, 8));
        await ds.updateStreak(now: DateTime(2026, 11, 10, 21));

        final data = await user();
        expect(data['streak'], 4);
        expect(data['name'], 'Alice', reason: 'merge keeps other fields');
        expect(
          (data['lastActiveDate'] as Timestamp).toDate(),
          DateTime(2026, 11, 10, 8),
        );
      },
    );
  });
}
