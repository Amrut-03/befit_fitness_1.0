import 'package:fitness_app/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fitness_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class GetUserProfile {
  final OnboardingRepository repository;

  GetUserProfile(this.repository);

  Future<UserProfileEntity?> call() async {
    return await repository.getUserProfile();
  }
}
