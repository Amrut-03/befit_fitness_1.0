import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/profile/data/datasources/local/profile_local_datasources.dart';
import 'package:fitness_app/features/profile/data/datasources/remote/profile_remote_datasources.dart';

import '../../domain/entities/profile_entity.dart';

import '../../domain/repositories/profile_repository.dart';

import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDatasource localDatasource;

  final ProfileRemoteDatasource remoteDatasource;

  final FirebaseAuth auth;

  ProfileRepositoryImpl(this.localDatasource, this.remoteDatasource, this.auth);

  @override
  Future<ProfileEntity> getProfile() async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      throw Exception("User not logged in");
    }

    final remoteProfile = await remoteDatasource.getProfile(uid);

    if (remoteProfile != null) {
      await localDatasource.saveProfile(remoteProfile);

      return remoteProfile;
    }

    final localProfile = await localDatasource.getProfile();

    if (localProfile != null) {
      return localProfile;
    }

    return const ProfileModel(
      name: '',

      email: '',

      goal: 'Fitness Goal',

      streak: 0,

      weight: 0,

      height: 0,

      age: 0,

      gender: 'Male',

      dailyStepGoal: 0,

      dailyCalorieGoal: 0,

      proteinGoal: 0,

      carbsGoal: 0,

      fatGoal: 0,

      activityLevel: 'Sedentary',
    );
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      throw Exception("User not logged in");
    }

    final model = ProfileModel(
      name: profile.name,

      email: profile.email,

      goal: profile.goal,

      streak: profile.streak,

      weight: profile.weight,

      height: profile.height,

      age: profile.age,

      gender: profile.gender,

      photoUrl: profile.photoUrl,

      dailyStepGoal: profile.dailyStepGoal,

      dailyCalorieGoal: profile.dailyCalorieGoal,
      proteinGoal: profile.proteinGoal,
      carbsGoal: profile.carbsGoal,
      fatGoal: profile.fatGoal,
      activityLevel: profile.activityLevel,
    );

    await remoteDatasource.updateProfile(uid, model);

    await localDatasource.saveProfile(model);
  }
}
