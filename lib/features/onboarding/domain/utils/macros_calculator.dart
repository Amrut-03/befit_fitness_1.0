class MacroCalculator {
  static Map<String, double> calculate({
    required int calories,
    required String goal,
  }) {
    double proteinPercent;
    double carbsPercent;
    double fatPercent;

    switch (goal) {
      case 'Lose Weight':
        proteinPercent = 0.40;
        carbsPercent = 0.30;
        fatPercent = 0.30;
        break;

      case 'Build Muscle':
        proteinPercent = 0.30;
        carbsPercent = 0.45;
        fatPercent = 0.25;
        break;

      case 'Improve Endurance':
        proteinPercent = 0.25;
        carbsPercent = 0.55;
        fatPercent = 0.20;
        break;

      default:
        proteinPercent = 0.30;
        carbsPercent = 0.40;
        fatPercent = 0.30;
    }

    return {
      "protein": (calories * proteinPercent) / 4,
      "carbs": (calories * carbsPercent) / 4,
      "fat": (calories * fatPercent) / 9,
    };
  }
}
