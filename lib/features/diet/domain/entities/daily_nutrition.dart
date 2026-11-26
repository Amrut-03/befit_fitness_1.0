import 'package:equatable/equatable.dart';

import 'meal_entity.dart';

/// What was eaten on one day, from the meals ticked off in diet plans.
class DailyNutrition extends Equatable {
  const DailyNutrition({
    required this.day,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  /// Local midnight.
  final DateTime day;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  /// Sums the meals consumed on [day] across every plan.
  factory DailyNutrition.fromMeals(DateTime day, Iterable<MealEntity> meals) {
    final d = DateTime(day.year, day.month, day.day);
    var kcal = 0.0, p = 0.0, c = 0.0, f = 0.0;
    for (final m in meals) {
      final at = m.consumedAt;
      if (at == null ||
          at.year != d.year ||
          at.month != d.month ||
          at.day != d.day) {
        continue;
      }
      kcal += m.calories;
      p += m.protein;
      c += m.carbs;
      f += m.fat;
    }
    return DailyNutrition(day: d, calories: kcal, protein: p, carbs: c, fat: f);
  }

  bool get isEmpty => calories == 0 && protein == 0 && carbs == 0 && fat == 0;

  @override
  List<Object?> get props => [day, calories, protein, carbs, fat];
}
