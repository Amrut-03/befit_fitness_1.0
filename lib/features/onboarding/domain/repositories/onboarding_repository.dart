import 'package:fitness_app/features/onboarding/domain/entities/onboarding_entity.dart';

abstract class OnboardingRepository {
  Future<void> saveUserProfile(UserProfileEntity profile);
  Future<UserProfileEntity?> getUserProfile();
  Future<bool> isProfileCompleted();
}
