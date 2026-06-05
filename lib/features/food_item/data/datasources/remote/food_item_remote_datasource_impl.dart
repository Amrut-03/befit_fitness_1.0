import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/food_items_model.dart';

class FoodItemsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FoodItemsRemoteDataSource({required this.firestore, required this.auth});

  CollectionReference get foodRef => firestore
      .collection('users')
      .doc(auth.currentUser?.uid)
      .collection('foodItems');

  Stream<List<FoodItemModel>> getFoodItems() {
    return foodRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FoodItemModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> saveFoodItem(FoodItemModel item) async {
    await foodRef.doc(item.id).set(item.toJson());
  }

  Future<void> deleteFoodItem(String id) async {
    await foodRef.doc(id).delete();
  }

  Future<void> updateFoodItem(FoodItemModel item) async {
    await foodRef.doc(item.id).update(item.toJson());
  }
}
