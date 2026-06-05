class GoalCalculator {
  static int calculateStepGoal(String goal, String activityLevel) {
    switch (goal) {
      case 'Lose Weight':
        return 12000;
      case 'Build Muscle':
        return 8000;
      case 'Stay Fit':
        return 10000;
      case 'Improve Endurance':
        return 15000;
      default:
        return 10000;
    }
  }

  static int calculateDailyCalories({
    required String gender,
    required double weight,
    required double height,
    required int age,
    required String activityLevel,
  }) {
    double bmr;
    if (gender == 'Male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    double multiplier;

    switch (activityLevel) {
      case 'Sedentary':
        multiplier = 1.2;
        break;

      case 'Light':
        multiplier = 1.375;
        break;

      case 'Moderate':
        multiplier = 1.55;
        break;

      case 'Active':
        multiplier = 1.725;
        break;

      default:
        multiplier = 1.55;
    }

    return (bmr * multiplier).round();
  }
}
