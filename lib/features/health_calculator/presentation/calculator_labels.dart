import 'package:fitness_app/core/l10n/l10n.dart';

/// Calculator types and goals travel through routes and use cases as their
/// English values; these map them to the current language for display.
String calculatorTypeLabel(AppLocalizations l10n, String type) =>
    switch (type) {
      'BMI' => l10n.calcTypeBmi,
      'Water Intake' => l10n.calcTypeWater,
      'Protein' => l10n.calcTypeProtein,
      'Calories' => l10n.calcTypeCalories,
      _ => type,
    };

String calculatorTitle(AppLocalizations l10n, String type) => switch (type) {
  'BMI' => l10n.calcBmiTitle,
  'Water Intake' => l10n.calcWaterTitle,
  'Protein' => l10n.calcProteinTitle,
  _ => l10n.calcCaloriesTitle,
};

String calculatorSubtitle(AppLocalizations l10n, String type) => switch (type) {
  'BMI' => l10n.calcBmiSubtitle,
  'Water Intake' => l10n.calcWaterSubtitle,
  'Protein' => l10n.calcProteinSubtitle,
  _ => l10n.calcCaloriesSubtitle,
};

String proteinGoalLabel(AppLocalizations l10n, String goal) => switch (goal) {
  'Maintain' => l10n.calcGoalMaintain,
  'Fat Loss' => l10n.calcGoalFatLoss,
  'Muscle Gain' => l10n.calcGoalMuscleGain,
  _ => goal,
};
