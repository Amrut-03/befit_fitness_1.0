import 'package:firebase_ai/firebase_ai.dart';
import 'package:fitness_app/core/config/app_config.dart';

import '../../domain/services/coach_prompt_builder.dart';

/// Streams coach answers from Gemini through Firebase AI Logic (no API key in
/// the app). Used when the on-device model isn't available.
class CoachCloudDatasource {
  CoachCloudDatasource(this._stream);

  factory CoachCloudDatasource.gemini() {
    final model = FirebaseAI.googleAI().generativeModel(
      model: AppConfig.aiInsightsModel,
      systemInstruction: Content.system(CoachPromptBuilder.systemInstruction),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 512,
      ),
    );
    return CoachCloudDatasource(
      (prompt) => model
          .generateContentStream([Content.text(prompt)])
          .map((r) => r.text ?? ''),
    );
  }

  final Stream<String> Function(String prompt) _stream;

  Stream<String> stream(String prompt) =>
      _stream(prompt).where((t) => t.isNotEmpty);
}
