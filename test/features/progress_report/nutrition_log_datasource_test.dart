import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/diet/data/datasources/remote/nutrition_log_remote_datasource.dart';
import 'package:fitness_app/features/diet/domain/entities/daily_nutrition.dart';
import 'package:flutter_test/flutter_test.dart';

class _User extends Fake implements User {
  @override
  String get uid => 'u1';
}

class _Auth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => _User();
}

void main() {
  late FakeFirebaseFirestore db;
  late NutritionLogRemoteDatasource ds;

  setUp(() {
    db = FakeFirebaseFirestore();
    ds = NutritionLogRemoteDatasource(firestore: db, auth: _Auth());
  });

  test('record overwrites the day; un-ticking can bring it to zero', () async {
    final day = DateTime(2026, 11, 12);
    await ds.record(DailyNutrition(day: day, calories: 800, protein: 60));
    await ds.record(DailyNutrition(day: day, calories: 400, protein: 30));

    final doc = await db
        .collection('users/u1/nutritionLog')
        .doc('2026-11-12')
        .get();
    expect(doc['calories'], 400);
    expect(doc['protein'], 30);
  });

  test('getRange returns days within the range, oldest first', () async {
    for (final d in [9, 10, 13, 16, 17]) {
      await ds.record(
        DailyNutrition(day: DateTime(2026, 11, d), calories: d * 100.0),
      );
    }

    final days = await ds.getRange(
      DateTime(2026, 11, 10),
      DateTime(2026, 11, 16),
    );

    expect(days.map((d) => d.day.day), [10, 13, 16]);
    expect(days.first.calories, 1000);
  });
}
