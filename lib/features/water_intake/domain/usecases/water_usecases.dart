import '../entities/water_day.dart';
import '../entities/water_entry.dart';
import '../repositories/water_intake_repository.dart';

class WatchWaterDay {
  WatchWaterDay(this._repo);
  final WaterIntakeRepository _repo;

  Stream<WaterDay> call(DateTime day, {required int goalMl}) =>
      _repo.watchDay(day, goalMl: goalMl);
}

class GetWaterHistory {
  GetWaterHistory(this._repo);
  final WaterIntakeRepository _repo;

  Future<List<WaterDay>> call({int days = 7, required int goalMl}) =>
      _repo.getHistory(days: days, goalMl: goalMl);
}

class GetWaterRange {
  GetWaterRange(this._repo);
  final WaterIntakeRepository _repo;

  Future<List<WaterDay>> call(
    DateTime from, {
    required int days,
    required int goalMl,
  }) => _repo.getRange(from, days: days, goalMl: goalMl);
}

class AddWater {
  AddWater(this._repo);
  final WaterIntakeRepository _repo;

  Future<void> call(int ml, {required int goalMl}) {
    if (ml <= 0 || ml > 3000) {
      throw ArgumentError.value(ml, 'ml', 'must be between 1 and 3000');
    }
    return _repo.addEntry(ml, goalMl: goalMl);
  }
}

class RemoveWater {
  RemoveWater(this._repo);
  final WaterIntakeRepository _repo;

  Future<void> call(DateTime day, WaterEntry entry) =>
      _repo.removeEntry(day, entry);
}

class GetWaterGoal {
  GetWaterGoal(this._repo);
  final WaterIntakeRepository _repo;

  Future<int> call() => _repo.getGoalMl();
}

class GetRecommendedWaterGoal {
  GetRecommendedWaterGoal(this._repo);
  final WaterIntakeRepository _repo;

  Future<int> call() => _repo.getRecommendedGoalMl();
}

class SetWaterGoal {
  SetWaterGoal(this._repo);
  final WaterIntakeRepository _repo;

  Future<void> call(int ml) => _repo.setGoalMl(ml);
}
