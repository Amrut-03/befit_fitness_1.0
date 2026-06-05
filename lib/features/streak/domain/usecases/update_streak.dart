import 'package:fitness_app/features/streak/domain/repository/streak_repository.dart';

class UpdateStreak {
  final StreakRepository repository;

  UpdateStreak(this.repository);

  Future<void> call() {
    return repository.updateStreak();
  }
}
