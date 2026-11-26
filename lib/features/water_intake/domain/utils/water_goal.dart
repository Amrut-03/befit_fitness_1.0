/// Daily water goal rules.
abstract final class WaterGoal {
  /// Used when the profile has no weight.
  static const fallbackMl = 2500;

  static const minMl = 500;
  static const maxMl = 6000;

  /// Quick-add sizes shown in the UI.
  static const quickAddMl = [150, 250, 500, 750];

  /// The common guideline of 35 ml per kg of body weight, rounded to the
  /// nearest 50 ml and kept within [minMl]..[maxMl]. Matches the Water
  /// Intake calculator.
  static int recommendedMl(double? weightKg) {
    if (weightKg == null || weightKg <= 0) return fallbackMl;
    final ml = (weightKg * 35 / 50).round() * 50;
    return ml.clamp(minMl, maxMl);
  }

  static bool isValid(int ml) => ml >= minMl && ml <= maxMl;

  /// The Firestore document id for [day]: `yyyy-MM-dd` in local time.
  static String dayKey(DateTime day) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${day.year}-${two(day.month)}-${two(day.day)}';
  }

  static DateTime startOfDay(DateTime t) => DateTime(t.year, t.month, t.day);
}
