import 'dart:convert';
import 'package:fitness_app/core/config/secrets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fitness_app/features/ai_insights/data/models/ai_insight_model.dart';

class AIInsightsRemoteDatasource {
  Future<List<AIInsightModel>> generateInsights({
    required int steps,

    required int calories,

    required int streak,

    required double bmi,
  }) async {
    final prompt =
        '''

You are a professional AI fitness coach.

Analyze this fitness data:

Steps: $steps
Calories Burned: $calories
Workout Streak: $streak
BMI: $bmi

Generate exactly 4 short fitness insights.

Rules:
- concise
- motivational
- premium fitness app tone
- each insight on separate line
- emoji at beginning

Example:

🔥 Excellent activity today.
💪 Your streak is impressive.
🚶 You crossed 10k steps.
⚡ Consistency creates results.

''';

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=${Secrets.googleGeminiApiKey}',
      ),

      headers: {'Content-Type': 'application/json'},

      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      print("Error response: ${response.body}");
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);

    final text = data['candidates'][0]['content']['parts'][0]['text']
        .toString();

    final lines = text.split('\n').where((e) => e.trim().isNotEmpty).toList();

    return lines.map((line) {
      final emoji = line.trim().isNotEmpty ? line.characters.first : "🤖";

      return AIInsightModel(
        title: "AI Coach",

        message: line.trim(),

        emoji: emoji,
      );
    }).toList();
  }
}
