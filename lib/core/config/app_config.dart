class AppConfig {
  AppConfig._();

  /// Open-source ExerciseDB API (no API key required).
  /// Docs: https://docs.exercisedb.dev
  static const String exerciseDbBaseUrl = 'https://oss.exercisedb.dev/api/v1';

  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org';

  /// Open Food Facts asks apps to identify themselves with a descriptive
  /// User-Agent (app name, version and a contact URL).
  static const String userAgent =
      'BeFit/1.0 (Android; +https://github.com/Amrut-03/befit_fitness_1.0)';

  /// Timeout for third-party HTTP calls.
  static const Duration httpTimeout = Duration(seconds: 12);

  /// Gemini model used via Firebase AI Logic for home-screen insights.
  /// Change here if Google retires the model.
  static const String aiInsightsModel = 'gemini-3.1-flash-lite';
}
