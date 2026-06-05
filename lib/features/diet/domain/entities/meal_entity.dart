class MealEntity {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double quantity;
  final String unit;
  final DateTime? consumedAt;
  final DateTime? alarmTime;

  const MealEntity({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.quantity = 100,
    this.unit = 'g',
    this.alarmTime,
    this.consumedAt,
  });

  bool get isConsumedToday {
    if (consumedAt == null) return false;

    final now = DateTime.now();

    return consumedAt!.year == now.year &&
        consumedAt!.month == now.month &&
        consumedAt!.day == now.day;
  }

  MealEntity copyWith({
    String? id,
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? quantity,
    String? unit,
    DateTime? alarmTime,
    DateTime? consumedAt,
  }) {
    return MealEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      alarmTime: alarmTime ?? this.alarmTime,
      consumedAt: consumedAt ?? this.consumedAt,
    );
  }
}
