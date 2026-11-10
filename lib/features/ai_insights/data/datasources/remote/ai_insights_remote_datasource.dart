import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:fitness_app/core/config/app_config.dart';
import 'package:fitness_app/features/ai_insights/data/models/ai_insight_model.dart';

/// Generates fitness insights through Firebase AI Logic.
///
/// No API key ships with the app: requests are proxied by Firebase, which
/// holds the Gemini key server-side and attributes calls to this Firebase
/// project (protect further with App Check, see TASKS.md #3).
class AIInsightsRemoteDatasource {
  final GenerativeModel model;

  AIInsightsRemoteDatasource(this.model);

  static const int _insightCount = 4;

  /// Builds the Gemini model configured to return a JSON array of insights.
  static GenerativeModel createModel() {
    return FirebaseAI.googleAI().generativeModel(
      model: AppConfig.aiInsightsModel,
      systemInstruction: Content.system(
        'You are a professional fitness coach inside the BeFit app. '
        'Write short, motivational, premium-toned insights based only on the '
        'data provided. Never give medical diagnoses.',
      ),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        responseMimeType: 'application/json',
        responseSchema: Schema.array(
          minItems: _insightCount,
          maxItems: _insightCount,
          items: Schema.object(
            properties: {
              'emoji': Schema.string(description: 'A single emoji'),
              'title': Schema.string(description: '2-4 word headline'),
              'message': Schema.string(
                description: 'One sentence, max 20 words',
              ),
            },
            propertyOrdering: ['emoji', 'title', 'message'],
          ),
        ),
      ),
    );
  }

  Future<List<AIInsightModel>> generateInsights({
    required int steps,
    required int calories,
    required int streak,
    required double bmi,
  }) async {
    final prompt =
        'Analyze today\'s fitness data and generate exactly $_insightCount '
        'insights.\n'
        'Steps: $steps\n'
        'Calories burned: $calories\n'
        'Workout streak (days): $streak\n'
        'BMI: ${bmi.toStringAsFixed(1)}';

    final response = await model.generateContent([Content.text(prompt)]);

    return parseInsights(response.text);
  }

  /// Parses the model's JSON array response into at most four insights.
  static List<AIInsightModel> parseInsights(String? text) {
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('AI returned an empty response');
    }

    final decoded = jsonDecode(text);
    if (decoded is! List) {
      throw const FormatException('AI response was not a JSON array');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AIInsightModel.fromJson)
        .where((insight) => insight.message.isNotEmpty)
        .take(_insightCount)
        .toList();
  }
}
