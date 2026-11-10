import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/features/streak/data/models/streak_model.dart';
import 'package:fitness_app/features/streak/domain/utils/streak_calculator.dart';

class StreakRemoteDatasource {
  final FirebaseFirestore firestore;

  final FirebaseAuth auth;

  StreakRemoteDatasource({required this.firestore, required this.auth});

  /// Records activity for today. Runs in a transaction so two quick actions
  /// (e.g. saving a workout and ticking a meal) can't double-increment.
  Future<void> updateStreak({DateTime? now}) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw const UnauthenticatedException();

    final ref = firestore.collection('users').doc(uid);
    final at = now ?? DateTime.now();

    await firestore.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      final data = snapshot.data() ?? const <String, dynamic>{};
      final lastActive = data['lastActiveDate'] as Timestamp?;

      final updated = StreakCalculator.next(
        current: (data['streak'] as num?)?.toInt() ?? 0,
        lastActive: lastActive?.toDate(),
        now: at,
      );
      if (updated == null) return;

      final fields = {
        'streak': updated,
        'lastActiveDate': Timestamp.fromDate(at),
      };
      // update() alone throws if users/{uid} doesn't exist yet.
      if (snapshot.exists) {
        tx.update(ref, fields);
      } else {
        tx.set(ref, fields);
      }
    });
  }

  Future<StreakModel> getStreak() async {
    final uid = auth.currentUser?.uid;

    if (uid == null) throw const UnauthenticatedException();

    final doc = await firestore.collection('users').doc(uid).get();

    return StreakModel.fromJson(doc.data() ?? {});
  }
}
