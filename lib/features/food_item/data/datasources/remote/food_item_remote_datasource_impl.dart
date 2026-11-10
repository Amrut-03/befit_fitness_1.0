import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/error/exceptions.dart';

import '../../models/food_items_model.dart';

class FoodItemsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FoodItemsRemoteDataSource({required this.firestore, required this.auth});

  String get _uid {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw const UnauthenticatedException();
    return uid;
  }

  /// Builds the query when the stream is listened to, so a missing user
  /// surfaces as a stream error instead of a synchronous throw.
  Stream<T> _userStream<T>(Stream<T> Function() build) =>
      Stream<void>.value(null).asyncExpand((_) => build());

  CollectionReference get foodRef =>
      firestore.collection('users').doc(_uid).collection('foodItems');

  Stream<List<FoodItemModel>> getFoodItems() {
    return _userStream(() => foodRef.snapshots()).map((snapshot) {
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
    await foodRef.doc(item.id).set(item.toJson(), SetOptions(merge: true));
  }
}
