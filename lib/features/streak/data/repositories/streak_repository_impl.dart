import 'package:fitness_app/features/streak/data/datasources/remote/streak_remote_datasources.dart';
import 'package:fitness_app/features/streak/domain/entities/streak_entity.dart';

import 'package:fitness_app/features/streak/domain/repository/streak_repository.dart';

class StreakRepositoryImpl implements StreakRepository {
  final StreakRemoteDatasource remoteDatasource;

  StreakRepositoryImpl({required this.remoteDatasource});

  @override
  Future<void> updateStreak() async {
    await remoteDatasource.updateStreak();
  }

  @override
  Future<StreakEntity> getStreak() async {
    return await remoteDatasource.getStreak();
  }
}
