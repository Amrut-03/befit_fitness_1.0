class AppConfig {
  AppConfig._();

  /// Open-source ExerciseDB API (no API key required).
  /// Docs: https://docs.exercisedb.dev
  static const String exerciseDbBaseUrl = 'https://oss.exercisedb.dev/api/v1';

  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org';

  /// Gemini model used via Firebase AI Logic for home-screen insights.
  /// Change here if Google retires the model.
  static const String aiInsightsModel = 'gemini-3.1-flash-lite';
}
