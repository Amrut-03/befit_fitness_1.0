import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/features/water_intake/data/datasources/water_intake_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

class _User extends Fake implements User {
  @override
  String get uid => 'u1';
}

class _Auth extends Fake implements FirebaseAuth {
  _Auth({this.signedIn = true});
  final bool signedIn;

  @override
  User? get currentUser => signedIn ? _User() : null;
}

void main() {
  late FakeFirebaseFirestore db;
  late DateTime now;
  late WaterIntakeRemoteDatasource ds;

  setUp(() {
    db = FakeFirebaseFirestore();
    now = DateTime(2026, 11, 10, 9, 30);
    ds = WaterIntakeRemoteDatasource(
      firestore: db,
      auth: _Auth(),
      clock: () => now,
    );
  });

  CollectionReference<Map<String, dynamic>> water() =>
      db.collection('users').doc('u1').collection('waterIntake');

  test('addEntry appends to the day doc keyed yyyy-MM-dd', () async {
    await ds.addEntry(250, goalMl: 2000);
    now = now.add(const Duration(hours: 1));
    await ds.addEntry(500, goalMl: 2000);

    final doc = await water().doc('2026-11-10').get();
    expect(doc['goalMl'], 2000);
    expect((doc['date'] as Timestamp).toDate(), DateTime(2026, 11, 10));
    expect((doc['entries'] as List).cast<Map>().map((e) => e['ml']), [
      250,
      500,
    ]);
  });

  test('watchDay emits live totals, and removeEntry takes one out', () async {
    final day = DateTime(2026, 11, 10);
    final first = await ds.addEntry(250, goalMl: 2000);
    now = now.add(const Duration(minutes: 5));
    await ds.addEntry(250, goalMl: 2000);

    expect((await ds.watchDay(day, goalMl: 2000).first).totalMl, 500);

    await ds.removeEntry(day, first);

    final after = await ds.watchDay(day, goalMl: 2000).first;
    expect(after.totalMl, 250);
    expect(after.entries.single.id, isNot(first.id));
  });

  test('watchDay on an empty day uses the fallback goal', () async {
    final d = await ds.watchDay(DateTime(2026, 11, 10), goalMl: 1800).first;
    expect(d.totalMl, 0);
    expect(d.goalMl, 1800);
  });

  test('getHistory returns 7 days oldest first, filling empty days', () async {
    now = DateTime(2026, 11, 8, 8);
    await ds.addEntry(1000, goalMl: 2000);
    now = DateTime(2026, 11, 10, 8);
    await ds.addEntry(300, goalMl: 2500);
    // Older than the window: ignored.
    now = DateTime(2026, 11, 1, 8);
    await ds.addEntry(900, goalMl: 2000);
    now = DateTime(2026, 11, 10, 20);

    final days = await ds.getHistory(days: 7, goalMl: 3000);

    expect(days.map((d) => d.day.day), [4, 5, 6, 7, 8, 9, 10]);
    expect(days.map((d) => d.totalMl), [0, 0, 0, 0, 1000, 0, 300]);
    // Logged days keep the goal of that day; empty days use the current one.
    expect(days.map((d) => d.goalMl), [
      3000,
      3000,
      3000,
      3000,
      2000,
      3000,
      2500,
    ]);
  });

  test(
    'goal round-trips on users/{uid} without touching other fields',
    () async {
      await db.collection('users').doc('u1').set({'streak': 4});
      expect(await ds.getGoalMl(), isNull);

      await ds.setGoalMl(2750);

      expect(await ds.getGoalMl(), 2750);
      final user = await db.collection('users').doc('u1').get();
      expect(user['streak'], 4);
    },
  );

  test('throws UnauthenticatedException when signed out', () {
    final out = WaterIntakeRemoteDatasource(
      firestore: db,
      auth: _Auth(signedIn: false),
    );
    expect(
      () => out.addEntry(250, goalMl: 2000),
      throwsA(isA<UnauthenticatedException>()),
    );
  });
}
