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
    // merge: keep fields this model doesn't know about (profileCompleted,
    // lastActiveDate). A plain set() wiped them, sending the user back to
    // onboarding after editing their profile. The streak is owned by the
    // streak feature (transactional updates), so never overwrite it here.
    final json = profile.toJson()..remove('streak');
    await firestore
        .collection('users')
        .doc(uid)
        .set(json, SetOptions(merge: true));
  }
}
