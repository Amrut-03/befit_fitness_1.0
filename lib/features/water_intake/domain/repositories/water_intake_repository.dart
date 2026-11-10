import '../entities/water_day.dart';
import '../entities/water_entry.dart';

abstract class WaterIntakeRepository {
  /// Live updates for [day], including writes made while offline.
  Stream<WaterDay> watchDay(DateTime day, {required int goalMl});

  /// The last [days] days ending today, oldest first, with empty days filled.
  Future<List<WaterDay>> getHistory({required int days, required int goalMl});

  Future<void> addEntry(int ml, {required int goalMl});

  Future<void> removeEntry(DateTime day, WaterEntry entry);

  /// The user's goal, or the weight-based recommendation if they haven't set
  /// one.
  Future<int> getGoalMl();

  /// The weight-based recommendation, shown when editing the goal.
  Future<int> getRecommendedGoalMl();

  Future<void> setGoalMl(int ml);
}
