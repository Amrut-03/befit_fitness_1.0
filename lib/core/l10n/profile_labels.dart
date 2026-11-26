import 'l10n.dart';

/// Goals, genders and activity levels are stored (and used in calculations)
/// as their English values; these map them to the current language for
/// display. Unknown values are shown as stored.
String goalLabel(AppLocalizations l10n, String value) => switch (value) {
  'Build Muscle' => l10n.goalBuildMuscle,
  'Lose Weight' => l10n.goalLoseWeight,
  'Stay Fit' => l10n.goalStayFit,
  'Improve Strength' => l10n.goalImproveStrength,
  _ => value,
};

String genderLabel(AppLocalizations l10n, String value) => switch (value) {
  'Male' => l10n.genderMale,
  'Female' => l10n.genderFemale,
  'Prefer Not To Say' => l10n.genderPreferNot,
  _ => value,
};

String activityLabel(AppLocalizations l10n, String value) => switch (value) {
  'Sedentary' => l10n.activitySedentary,
  'Lightly Active' => l10n.activityLight,
  'Active' => l10n.activityActive,
  'Athlete' => l10n.activityAthlete,
  _ => value,
};

/// Default meal names are stored in English.
String mealLabel(AppLocalizations l10n, String value) => switch (value) {
  'Breakfast' => l10n.mealBreakfast,
  'Lunch' => l10n.mealLunch,
  'Dinner' => l10n.mealDinner,
  'Snack' => l10n.mealSnack,
  _ => value,
};

/// Food quantity units are stored in English; symbols stay as they are.
String foodUnitLabel(AppLocalizations l10n, String unit) => switch (unit) {
  'piece' => l10n.foodUnitPiece,
  'slice' => l10n.foodUnitSlice,
  'cup' => l10n.foodUnitCup,
  _ => unit,
};
