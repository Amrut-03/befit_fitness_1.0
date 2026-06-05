import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/features/profile/data/models/profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<ProfileModel?> getProfile(String uid);

  Future<void> updateProfile(String uid, ProfileModel profile);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final FirebaseFirestore firestore;

  ProfileRemoteDatasourceImpl(this.firestore);

  @override
  Future<ProfileModel?> getProfile(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return ProfileModel.fromJson(doc.data()!);
  }

  @override
  Future<void> updateProfile(String uid, ProfileModel profile) async {
    await firestore.collection('users').doc(uid).set(profile.toJson());
  }
}
