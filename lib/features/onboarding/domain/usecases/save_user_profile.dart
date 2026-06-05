import 'package:fitness_app/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fitness_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class SaveUserProfile {
  final OnboardingRepository repository;

  SaveUserProfile(this.repository);

  Future<void> call(UserProfileEntity profile) async {
    await repository.saveUserProfile(profile);
  }
}
