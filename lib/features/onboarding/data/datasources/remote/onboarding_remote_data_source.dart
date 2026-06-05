import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/onboarding/data/models/onboarding_model.dart';

class OnboardingRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  OnboardingRemoteDatasource({required this.firestore, required this.auth});

  Future<void> saveUserProfile(UserProfileModel profile) async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      throw Exception("User not logged in");
    }

    await firestore
        .collection('users')
        .doc(uid)
        .set(profile.toJson(), SetOptions(merge: true));
  }

  Future<UserProfileModel?> getUserProfile() async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      return null;
    }

    final doc = await firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return UserProfileModel.fromJson(doc.data()!);
  }

  Future<bool> isProfileCompleted() async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      return false;
    }

    final doc = await firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      return false;
    }

    return doc.data()?['profileCompleted'] == true;
  }
}
