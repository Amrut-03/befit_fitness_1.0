/// Every route path in one place. Use these instead of string literals.
abstract final class Routes {
  static const splash = '/';
  static const intro = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const history = '/history';

  // Onboarding (profile setup)
  static const goalSelection = '/goal-selection';
  static const genderSelection = '/gender-selection';
  static const bodyMetrics = '/body-metrics';
  static const activityLevel = '/activity-level';

  // Diet & food
  static const dietList = '/diet-list';
  static const planDiet = '/plan-diet';
  static const dietHistory = '/diet-history';
  static const foodItems = '/food-items';
  static const manualFoodEntry = '/manual-food-entry';
  static const barcodeScanner = '/barcode-food-entry';

  // Workouts
  static const workout = '/workout';
  static const workoutHistory = '/workout-history';
  static const workoutSession = '/workout-session';

  // Health calculators
  static const healthCalculators = '/health-calculators';
  static const healthCalculatorPath = '/health-calculator';

  /// A calculator by type (e.g. "BMI", "Water Intake"), passed as a query
  /// parameter so the route survives deep links and state restoration.
  static String healthCalculator(String type) => Uri(
    path: healthCalculatorPath,
    queryParameters: {'type': type},
  ).toString();

  // AI coach
  static const coach = '/coach';

  // Progress
  static const weeklyReport = '/weekly-report';

  // Water
  static const water = '/water';

  // Notifications
  static const notifications = '/notification-page';
  static const notificationSettings = '/notification-setting-page';
}
