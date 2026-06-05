class MacroEntity {
  final double carbs;
  final double protein;
  final double fat;

  MacroEntity({required this.carbs, required this.protein, required this.fat});

  double get overall => (carbs + protein + fat) / 3;
}
