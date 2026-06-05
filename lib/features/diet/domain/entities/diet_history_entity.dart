class DietHistoryEntity {
  final String id;

  final String planId;

  final String planName;

  final double calories;

  final double protein;

  final double carbs;

  final double fat;

  final DateTime completedAt;

  final List<String> meals;

  const DietHistoryEntity({
    required this.id,

    required this.planName,

    required this.calories,

    required this.protein,

    required this.carbs,

    required this.fat,

    required this.completedAt,

    required this.planId,

    required this.meals,
  });
}
