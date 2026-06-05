import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitness_app/features/streak/data/models/streak_model.dart';

class StreakRemoteDatasource {
  final FirebaseFirestore firestore;

  final FirebaseAuth auth;

  StreakRemoteDatasource({required this.firestore, required this.auth});

  Future<void> updateStreak() async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      throw Exception('User not logged in');
    }

    final doc = await firestore.collection('users').doc(uid).get();

    final data = doc.data();

    final currentStreak = data?['streak'] ?? 0;

    final lastActive = data?['lastActiveDate'];

    final now = DateTime.now();

    DateTime? lastDate;

    if (lastActive != null) {
      lastDate = (lastActive as Timestamp).toDate();
    }

    int updatedStreak = 1;

    if (lastDate != null) {
      final difference = now
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;

      /// SAME DAY
      if (difference == 0) {
        return;
      }

      /// CONTINUE STREAK
      if (difference == 1) {
        updatedStreak = currentStreak + 1;
      }
    }

    await firestore.collection('users').doc(uid).update({
      'streak': updatedStreak,

      'lastActiveDate': Timestamp.fromDate(now),
    });
  }

  Future<StreakModel> getStreak() async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      throw Exception('User not logged in');
    }

    final doc = await firestore.collection('users').doc(uid).get();

    return StreakModel.fromJson(doc.data() ?? {});
  }
}
