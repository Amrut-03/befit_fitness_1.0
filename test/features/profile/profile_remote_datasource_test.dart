import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fitness_app/features/profile/data/datasources/remote/profile_remote_datasources.dart';
import 'package:fitness_app/features/profile/data/models/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'updateProfile keeps onboarding/streak fields it does not own',
    () async {
      final firestore = FakeFirebaseFirestore();
      final last = Timestamp.fromDate(DateTime(2026, 11, 10));
      await firestore.doc('users/alice').set({
        'name': 'Old',
        'profileCompleted': true,
        'streak': 7,
        'lastActiveDate': last,
      });

      await ProfileRemoteDatasourceImpl(firestore).updateProfile(
        'alice',
        const ProfileModel(
          name: 'Alice',
          email: 'a@example.com',
          goal: 'Lose Weight',
          streak: 0, // stale value from the edit screen
          weight: 60,
          height: 165,
          age: 30,
          gender: 'Female',
          dailyStepGoal: 8000,
          dailyCalorieGoal: 1800,
          proteinGoal: 100,
          carbsGoal: 200,
          fatGoal: 60,
          activityLevel: 'Active',
        ),
      );

      final data = (await firestore.doc('users/alice').get()).data()!;
      expect(data['name'], 'Alice');
      expect(data['profileCompleted'], isTrue);
      expect(data['streak'], 7);
      expect(data['lastActiveDate'], last);
    },
  );
}
