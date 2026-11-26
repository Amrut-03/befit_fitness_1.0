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

  /// Download URL of the on-device Gemma model (a MediaPipe `.task` file,
  /// e.g. Gemma 3 1B int4 from litert-community/Gemma3-1B-IT), self-hosted
  /// because Hugging Face gates Gemma behind a login. Passed at build time:
  /// `--dart-define=GEMMA_MODEL_URL=https://...`. Empty disables on-device AI
  /// and the app uses Gemini in the cloud only.
  static const String onDeviceModelUrl = String.fromEnvironment(
    'GEMMA_MODEL_URL',
  );

  /// Shown before the user starts the model download.
  static const String onDeviceModelSize = 'about 550 MB';
}
