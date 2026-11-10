import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/error/exceptions.dart';

import '../../domain/entities/water_day.dart';
import '../../domain/entities/water_entry.dart';
import '../../domain/utils/water_goal.dart';
import '../models/water_day_model.dart';

/// Firestore access for water intake. Writes use `arrayUnion`/`arrayRemove`
/// with merge, never transactions, so logging works offline and syncs later.
class WaterIntakeRemoteDatasource {
  WaterIntakeRemoteDatasource({
    required this.firestore,
    required this.auth,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  static const collection = 'waterIntake';
  static const goalField = 'dailyWaterGoalMl';

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final DateTime Function() _now;

  DocumentReference<Map<String, dynamic>> get _user {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw const UnauthenticatedException();
    return firestore.collection('users').doc(uid);
  }

  DocumentReference<Map<String, dynamic>> _dayDoc(DateTime day) =>
      _user.collection(collection).doc(WaterGoal.dayKey(day));

  Stream<WaterDay> watchDay(DateTime day, {required int goalMl}) {
    final start = WaterGoal.startOfDay(day);
    return _dayDoc(start).snapshots().map(
      (s) =>
          WaterDayModel.fromJson(s.data(), day: start, fallbackGoalMl: goalMl),
    );
  }

  Future<List<WaterDay>> getHistory({
    required int days,
    required int goalMl,
  }) async {
    final today = WaterGoal.startOfDay(_now());
    final from = DateTime(today.year, today.month, today.day - (days - 1));

    final snap = await _user
        .collection(collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .orderBy('date')
        .get();

    final byDay = <DateTime, WaterDay>{};
    for (final doc in snap.docs) {
      final day = WaterDayModel.dayOf(doc.data());
      if (day == null) continue;
      byDay[day] = WaterDayModel.fromJson(
        doc.data(),
        day: day,
        fallbackGoalMl: goalMl,
      );
    }

    return [
      for (var i = 0; i < days; i++)
        () {
          final d = DateTime(from.year, from.month, from.day + i);
          return byDay[d] ?? WaterDay(day: d, goalMl: goalMl);
        }(),
    ];
  }

  Future<WaterEntry> addEntry(int ml, {required int goalMl}) async {
    final now = _now();
    final day = WaterGoal.startOfDay(now);
    final entry = WaterEntry(
      id: '${now.microsecondsSinceEpoch}',
      ml: ml,
      at: DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch),
    );
    await _dayDoc(day).set({
      'date': Timestamp.fromDate(day),
      'goalMl': goalMl,
      'entries': FieldValue.arrayUnion([WaterDayModel.entryToMap(entry)]),
    }, SetOptions(merge: true));
    return entry;
  }

  Future<void> removeEntry(DateTime day, WaterEntry entry) {
    return _dayDoc(WaterGoal.startOfDay(day)).update({
      'entries': FieldValue.arrayRemove([WaterDayModel.entryToMap(entry)]),
    });
  }

  Future<int?> getGoalMl() async {
    final data = (await _user.get()).data();
    final goal = data?[goalField];
    return goal is num ? goal.toInt() : null;
  }

  Future<void> setGoalMl(int ml) =>
      _user.set({goalField: ml}, SetOptions(merge: true));
}
