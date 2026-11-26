import 'package:fitness_app/features/streak/data/datasources/remote/streak_remote_datasources.dart';
import 'package:fitness_app/features/streak/domain/entities/streak_entity.dart';
import 'package:fitness_app/features/streak/domain/repositories/streak_repository.dart';
import 'package:fitness_app/features/streak/domain/utils/streak_calculator.dart';

class StreakRepositoryImpl implements StreakRepository {
  final StreakRemoteDatasource remoteDatasource;

  StreakRepositoryImpl({required this.remoteDatasource});

  @override
  Future<void> updateStreak() async {
    await remoteDatasource.updateStreak();
  }

  @override
  Future<StreakEntity> getStreak() async {
    final stored = await remoteDatasource.getStreak();
    return StreakEntity(
      currentStreak: StreakCalculator.effective(
        stored: stored.currentStreak,
        lastActive: stored.lastActiveDate,
        now: DateTime.now(),
      ),
      lastActiveDate: stored.lastActiveDate,
    );
  }
}
