import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/diet/data/models/diet_history_model.dart';
import 'package:fitness_app/features/diet/data/models/diet_plan_model.dart';
import 'package:fitness_app/features/diet/data/models/meal_model.dart';

class DietRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  DietRemoteDataSource({required this.firestore, required this.auth});

  CollectionReference<Map<String, dynamic>> get dietPlansRef => firestore
      .collection('users')
      .doc(auth.currentUser?.uid)
      .collection('dietPlans');

  Stream<List<DietPlanModel>> getDietPlans() {
    return dietPlansRef.snapshots().map((snapshot) {
      print("DOC COUNT: ${snapshot.docs.length}");

      for (final doc in snapshot.docs) {
        print("RAW FIRESTORE DOC = ${doc.data()}");
      }

      return snapshot.docs.map((doc) {
        final model = DietPlanModel.fromJson(doc.data());

        print("DATASOURCE MODEL ${model.name} ACTIVE=${model.activeDate}");

        return model;
      }).toList();
    });
  }

  Stream<DietPlanModel?> getActivePlan() {
    return dietPlansRef.snapshots().map((snapshot) {
      final now = DateTime.now();

      for (final doc in snapshot.docs) {
        final plan = DietPlanModel.fromJson(doc.data());

        final activeDate = plan.activeDate;

        if (activeDate == null) {
          continue;
        }

        final isToday =
            activeDate.year == now.year &&
            activeDate.month == now.month &&
            activeDate.day == now.day;

        if (isToday) {
          return plan;
        }
      }

      return null;
    });
  }

  Future<void> saveDietHistory(DietHistoryModel history) async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('dietHistory')
        .doc(history.id)
        .set(history.toJson());
  }

  Stream<List<DietHistoryModel>> getDietHistory() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('dietHistory')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DietHistoryModel.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> savePlan(DietPlanModel plan) async {
    await dietPlansRef.doc(plan.id).set(plan.toJson());
  }

  Future<void> deletePlan(String id) async {
    await dietPlansRef.doc(id).delete();
  }

  Future<void> updateMeals(String planId, List<MealModel> meals) async {
    await dietPlansRef.doc(planId).update({
      'meals': meals.map((e) => e.toJson()).toList(),
    });
  }

  Stream<Map<String, dynamic>> getMacros() {
    return getActivePlan().map((plan) {
      double carbs = 0;
      double protein = 0;
      double fat = 0;

      if (plan == null) {
        return {"carbs": 0.0, "protein": 0.0, "fat": 0.0};
      }

      for (final meal in plan.meals) {
        if (meal.isConsumedToday) {
          carbs += meal.carbs;
          protein += meal.protein;
          fat += meal.fat;
        }
      }

      return {"carbs": carbs, "protein": protein, "fat": fat};
    });
  }

  Future<void> setActiveDietPlan(String planId) async {
    final snapshot = await dietPlansRef.get();

    final batch = firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'activeDate': null});
    }

    final today = Timestamp.fromDate(DateTime.now());

    batch.update(dietPlansRef.doc(planId), {'activeDate': today});

    await batch.commit();
  }

  CollectionReference<Map<String, dynamic>> get historyRef => firestore
      .collection('users')
      .doc(auth.currentUser!.uid)
      .collection('dietHistory');

  Future<void> saveHistory(DietHistoryModel model) async {
    await historyRef.doc(model.id).set(model.toJson());
  }

  Stream<List<DietHistoryModel>> getHistory() {
    return historyRef.orderBy('completedAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => DietHistoryModel.fromJson(doc.data()))
          .toList();
    });
  }
}
