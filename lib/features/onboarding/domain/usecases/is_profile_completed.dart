import 'package:fitness_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class IsProfileCompleted {
  final OnboardingRepository repository;

  IsProfileCompleted(this.repository);

  Future<bool> call() async {
    return await repository.isProfileCompleted();
  }
}
