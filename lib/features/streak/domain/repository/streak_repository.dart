import 'package:fitness_app/features/streak/domain/entities/streak_entity.dart';

abstract class StreakRepository {
  Future<void> updateStreak();

  Future<StreakEntity> getStreak();
}
