import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/core/utils/json_read.dart';

import '../../../domain/entities/daily_nutrition.dart';
import '../../../domain/repositories/nutrition_log_repository.dart';

/// `users/{uid}/nutritionLog/{yyyy-MM-dd}`:
/// `{date: Timestamp, calories, protein, carbs, fat}`.
class NutritionLogRemoteDatasource implements NutritionLogRepository {
  NutritionLogRemoteDatasource({required this.firestore, required this.auth});

  static const collection = 'nutritionLog';

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CollectionReference<Map<String, dynamic>> get _ref {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw const UnauthenticatedException();
    return firestore.collection('users').doc(uid).collection(collection);
  }

  static String dayKey(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  @override
  Future<void> record(DailyNutrition day) {
    return _ref.doc(dayKey(day.day)).set({
      'date': Timestamp.fromDate(day.day),
      'calories': day.calories,
      'protein': day.protein,
      'carbs': day.carbs,
      'fat': day.fat,
    });
  }

  @override
  Future<List<DailyNutrition>> getRange(DateTime from, DateTime to) async {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day + 1);
    final snap = await _ref
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .get();

    return [
      for (final doc in snap.docs)
        if (doc.data()['date'] is Timestamp)
          () {
            final j = doc.data();
            final d = (j['date'] as Timestamp).toDate();
            return DailyNutrition(
              day: DateTime(d.year, d.month, d.day),
              calories: asDouble(j['calories']),
              protein: asDouble(j['protein']),
              carbs: asDouble(j['carbs']),
              fat: asDouble(j['fat']),
            );
          }(),
    ];
  }
}
