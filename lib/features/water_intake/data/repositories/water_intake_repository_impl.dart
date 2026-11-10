import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';

import '../../domain/entities/water_day.dart';
import '../../domain/entities/water_entry.dart';
import '../../domain/repositories/water_intake_repository.dart';
import '../../domain/utils/water_goal.dart';
import '../datasources/water_intake_remote_datasource.dart';

class WaterIntakeRepositoryImpl implements WaterIntakeRepository {
  WaterIntakeRepositoryImpl(this._remote, this._getUserProfile);

  final WaterIntakeRemoteDatasource _remote;
  final GetUserProfile _getUserProfile;

  @override
  Stream<WaterDay> watchDay(DateTime day, {required int goalMl}) =>
      _remote.watchDay(day, goalMl: goalMl);

  @override
  Future<List<WaterDay>> getHistory({required int days, required int goalMl}) =>
      _remote.getHistory(days: days, goalMl: goalMl);

  @override
  Future<void> addEntry(int ml, {required int goalMl}) =>
      _remote.addEntry(ml, goalMl: goalMl);

  @override
  Future<void> removeEntry(DateTime day, WaterEntry entry) =>
      _remote.removeEntry(day, entry);

  @override
  Future<int> getGoalMl() async =>
      await _remote.getGoalMl() ?? await getRecommendedGoalMl();

  @override
  Future<int> getRecommendedGoalMl() async {
    try {
      final profile = await _getUserProfile();
      return WaterGoal.recommendedMl(profile?.weight);
    } catch (_) {
      return WaterGoal.fallbackMl;
    }
  }

  @override
  Future<void> setGoalMl(int ml) {
    if (!WaterGoal.isValid(ml)) {
      throw ArgumentError.value(ml, 'ml', 'outside the allowed goal range');
    }
    return _remote.setGoalMl(ml);
  }
}
