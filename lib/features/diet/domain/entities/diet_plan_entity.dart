import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';

class DietPlanEntity {
  final String id;

  final String name;

  final List<MealEntity> meals;

  final DateTime? activeDate;

  DietPlanEntity({
    required this.id,

    required this.name,

    required this.meals,

    this.activeDate,
  }) : assert(true) {
    print("CONSTRUCTOR ACTIVE DATE = $activeDate");
  }

  int get totalMeals => meals.length;

  int get consumedMeals => meals.where((m) => m.isConsumedToday).length;

  double get totalCalories => meals.fold(0, (sum, m) => sum + m.calories);

  double get progress => meals.isEmpty ? 0 : consumedMeals / meals.length;

  bool get isCompletedToday {
    if (meals.isEmpty) {
      return false;
    }

    return meals.every((meal) => meal.isConsumedToday);
  }

  bool get isActiveToday {
    if (activeDate == null) {
      return false;
    }

    final now = DateTime.now();

    return activeDate!.year == now.year &&
        activeDate!.month == now.month &&
        activeDate!.day == now.day;
  }

  DietPlanEntity copyWith({
    String? id,

    String? name,

    List<MealEntity>? meals,

    DateTime? activeDate,
  }) {
    return DietPlanEntity(
      id: id ?? this.id,

      name: name ?? this.name,

      meals: meals ?? this.meals,

      activeDate: activeDate ?? this.activeDate,
    );
  }
}
