import '../entities/coach_context.dart';
import '../entities/coach_message.dart';

/// Builds the coach's system instruction and prompt.
///
/// Small on-device models have a short context window (about 2k tokens for
/// Gemma 3 1B), so the user's data is a terse fact list and only the last
/// few turns are replayed, each trimmed.
class CoachPromptBuilder {
  const CoachPromptBuilder({this.maxHistoryTurns = 4, this.maxTurnChars = 400});

  final int maxHistoryTurns;
  final int maxTurnChars;

  static const systemInstruction =
      'You are BeFit Coach, a friendly and practical fitness and nutrition '
      'coach inside the BeFit app. Use the user data provided to personalise '
      'your answer and quote their numbers when relevant. Keep answers short: '
      'at most 5 sentences or 5 bullet points. Give safe, general guidance '
      'only. Never diagnose, never prescribe medication or supplements doses, '
      'and suggest a doctor for pain, injury or medical conditions. If data is '
      'missing, say so briefly instead of guessing.';

  String build({
    required String question,
    required CoachContext context,
    List<CoachMessage> history = const [],
  }) {
    final b = StringBuffer();
    final facts = contextFacts(context);
    if (facts.isNotEmpty) {
      b.writeln('User data:');
      for (final f in facts) {
        b.writeln('- $f');
      }
      b.writeln();
    }

    final turns = history
        .where((m) => !m.failed && m.text.trim().isNotEmpty)
        .toList();
    final recent = turns.length > maxHistoryTurns
        ? turns.sublist(turns.length - maxHistoryTurns)
        : turns;
    if (recent.isNotEmpty) {
      b.writeln('Conversation so far:');
      for (final m in recent) {
        b.writeln('${m.isUser ? 'User' : 'Coach'}: ${_trim(m.text)}');
      }
      b.writeln();
    }

    b.write('User question: ${_trim(question.trim())}');
    return b.toString();
  }

  String _trim(String s) =>
      s.length <= maxTurnChars ? s : '${s.substring(0, maxTurnChars)}…';

  /// One short line per known fact.
  static List<String> contextFacts(CoachContext c) {
    String n(num v) => v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
    final bmi = c.bmi;
    return [
      if (c.name case final v? when v.isNotEmpty) 'Name: $v',
      if (c.goal case final v? when v.isNotEmpty) 'Goal: $v',
      if (c.age case final v? when v > 0) 'Age: $v',
      if (c.gender case final v? when v.isNotEmpty) 'Gender: $v',
      if (c.weightKg case final v? when v > 0) 'Weight: ${n(v)} kg',
      if (c.heightCm case final v? when v > 0) 'Height: ${n(v)} cm',
      if (bmi != null) 'BMI: ${bmi.toStringAsFixed(1)}',
      if (c.activityLevel case final v? when v.isNotEmpty) 'Activity level: $v',
      if (c.calorieGoal case final v? when v > 0) 'Daily calorie goal: $v kcal',
      if ((c.proteinGoal ?? 0) > 0 ||
          (c.carbsGoal ?? 0) > 0 ||
          (c.fatGoal ?? 0) > 0)
        'Macro goals: protein ${c.proteinGoal ?? 0} g, '
            'carbs ${c.carbsGoal ?? 0} g, fat ${c.fatGoal ?? 0} g',
      if (c.stepsToday case final v?)
        'Steps today: $v${c.stepGoal != null && c.stepGoal! > 0 ? ' of ${c.stepGoal}' : ''}',
      if (c.caloriesBurnedToday case final v?)
        'Active calories burned today: $v kcal',
      if (c.streakDays case final v?) 'Workout streak: $v days',
      if (c.waterTodayMl case final v?)
        'Water today: $v ml${c.waterGoalMl != null ? ' of ${c.waterGoalMl} ml' : ''}',
      if (c.weekWeightChangeKg case final v?)
        'Weight change vs last week: ${v > 0 ? '+' : ''}${v.toStringAsFixed(1)} kg',
      if (c.weekMacroAdherencePct case final v?)
        'Macro adherence this week: $v%'
            '${c.weekLoggedDays != null && c.weekDaysElapsed != null ? ' (${c.weekLoggedDays} of ${c.weekDaysElapsed} days logged)' : ''}',
      if (c.weekWorkouts case final v?)
        'Workouts this week: $v'
            '${c.weekWorkoutMinutes != null && c.weekWorkoutMinutes! > 0 ? ' (${c.weekWorkoutMinutes} min)' : ''}',
      if (c.weekWaterDaysMet case final v?)
        'Days water goal met this week: $v'
            '${c.weekDaysElapsed != null ? ' of ${c.weekDaysElapsed}' : ''}',
    ];
  }
}
