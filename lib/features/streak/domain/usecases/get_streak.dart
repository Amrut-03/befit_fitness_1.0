import 'package:fitness_app/features/streak/domain/entities/streak_entity.dart';

import 'package:fitness_app/features/streak/domain/repository/streak_repository.dart';

class GetStreak {
  final StreakRepository repository;

  GetStreak(this.repository);

  Future<StreakEntity> call() {
    return repository.getStreak();
  }
}
