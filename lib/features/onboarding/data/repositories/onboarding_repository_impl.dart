import 'package:fitness_app/features/onboarding/data/datasources/remote/onboarding_remote_data_source.dart';
import 'package:fitness_app/features/onboarding/data/models/onboarding_model.dart';
import 'package:fitness_app/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fitness_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDatasource remoteDatasource;

  OnboardingRepositoryImpl({required this.remoteDatasource});

  @override
  Future<void> saveUserProfile(UserProfileEntity profile) async {
    final model = UserProfileModel(
      email: profile.email,
      goal: profile.goal,
      gender: profile.gender,
      weight: profile.weight,
      height: profile.height,
      age: profile.age,
      activityLevel: profile.activityLevel,
      profileCompleted: profile.profileCompleted,
      dailyStepGoal: profile.dailyStepGoal,
      dailyCalorieGoal: profile.dailyCalorieGoal,
      proteinGoal: profile.proteinGoal,
      carbsGoal: profile.carbsGoal,
      fatGoal: profile.fatGoal,
    );

    await remoteDatasource.saveUserProfile(model);
  }

  @override
  Future<UserProfileEntity?> getUserProfile() async {
    return await remoteDatasource.getUserProfile();
  }

  @override
  Future<bool> isProfileCompleted() async {
    return await remoteDatasource.isProfileCompleted();
  }
}
