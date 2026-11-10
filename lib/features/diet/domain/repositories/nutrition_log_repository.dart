import '../entities/daily_nutrition.dart';

/// A per-day record of what was eaten, used by the weekly report. Meals only
/// keep today's `consumedAt`, so without this past days would be lost.
abstract class NutritionLogRepository {
  /// Overwrites the day's totals (ticking and un-ticking both re-record).
  Future<void> record(DailyNutrition day);

  /// Logged days in [from]..[to] (inclusive), oldest first.
  Future<List<DailyNutrition>> getRange(DateTime from, DateTime to);
}
