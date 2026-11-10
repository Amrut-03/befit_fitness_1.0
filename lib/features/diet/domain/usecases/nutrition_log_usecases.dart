import '../entities/daily_nutrition.dart';
import '../repositories/nutrition_log_repository.dart';

class RecordDailyNutrition {
  RecordDailyNutrition(this._repo);
  final NutritionLogRepository _repo;

  Future<void> call(DailyNutrition day) => _repo.record(day);
}

class GetNutritionLog {
  GetNutritionLog(this._repo);
  final NutritionLogRepository _repo;

  Future<List<DailyNutrition>> call(DateTime from, DateTime to) =>
      _repo.getRange(from, to);
}
