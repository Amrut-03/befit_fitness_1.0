import 'dart:async';
import 'dart:convert';

import 'package:fitness_app/core/ai/on_device_llm.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/remote/ai_insights_remote_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/models/ai_insight_model.dart';

/// Generates the Home insights with the on-device model: offline, and the
/// user's numbers never leave the phone.
///
/// Small models can't be forced into a JSON schema the way Gemini can, so the
/// prompt shows the exact format and [parseLenient] recovers the array from
/// whatever surrounds it (code fences, a preamble, a truncated tail).
class AIInsightsOnDeviceDatasource {
  AIInsightsOnDeviceDatasource(
    this.llm, {
    this.timeout = const Duration(seconds: 90),
  });

  final OnDeviceLlm llm;
  final Duration timeout;

  static const _system =
      'You are a professional fitness coach inside the BeFit app. Write '
      'short, motivational insights based only on the data provided. Never '
      'give medical diagnoses. Reply with JSON only.';

  Future<bool> get isReady async =>
      await llm.status() == OnDeviceModelStatus.ready;

  Future<List<AIInsightModel>> generateInsights({
    required int steps,
    required int calories,
    required int streak,
    required double bmi,
  }) async {
    final prompt =
        "Today's fitness data:\n"
        '- Steps: $steps\n'
        '- Active calories burned: $calories\n'
        '- Workout streak: $streak days\n'
        '- BMI: ${bmi.toStringAsFixed(1)}\n\n'
        'Write exactly 4 insights as a JSON array. Each item has "emoji" (one '
        'emoji), "title" (2-4 words) and "message" (one sentence, at most 20 '
        'words). Format:\n'
        '[{"emoji":"🔥","title":"Short title","message":"One sentence."}]';

    final tokens = await llm.generate(
      prompt,
      systemInstruction: _system,
      temperature: 0.6,
    );
    final buffer = StringBuffer();
    final sub = tokens.listen(buffer.write);
    try {
      await sub.asFuture<void>().timeout(timeout);
    } finally {
      await sub.cancel();
    }

    final insights = parseLenient(buffer.toString());
    if (insights.length < 2) {
      throw const FormatException('On-device model returned too few insights');
    }
    return insights;
  }

  /// Extracts insights from free-form model output.
  static List<AIInsightModel> parseLenient(String text) {
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start != -1 && end > start) {
      try {
        return AIInsightsRemoteDatasource.parseInsights(
          text.substring(start, end + 1),
        );
      } on FormatException {
        // Fall through to per-object recovery.
      }
    }

    // Recover complete objects one by one (e.g. the array was cut off).
    final objects = RegExp(r'\{[^{}]*\}').allMatches(text);
    final out = <AIInsightModel>[];
    for (final m in objects) {
      try {
        final decoded = jsonDecode(m.group(0)!);
        if (decoded is Map<String, dynamic>) {
          final insight = AIInsightModel.fromJson(decoded);
          if (insight.message.isNotEmpty) out.add(insight);
        }
      } on FormatException {
        continue;
      }
      if (out.length == 4) break;
    }
    return out;
  }
}
