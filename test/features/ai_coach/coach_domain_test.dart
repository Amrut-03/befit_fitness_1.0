import 'package:fitness_app/features/ai_coach/domain/entities/coach_context.dart';
import 'package:fitness_app/features/ai_coach/domain/entities/coach_delta.dart';
import 'package:fitness_app/features/ai_coach/domain/entities/coach_message.dart';
import 'package:fitness_app/features/ai_coach/domain/services/coach_prompt_builder.dart';
import 'package:fitness_app/features/ai_coach/domain/repositories/coach_repository.dart';
import 'package:fitness_app/features/ai_coach/domain/services/coach_safety.dart';
import 'package:fitness_app/features/ai_coach/domain/usecases/ask_coach.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements CoachRepository {
  final prompts = <String>[];

  @override
  Stream<CoachDelta> reply(String prompt) {
    prompts.add(prompt);
    return Stream.value(const CoachDelta('ok', CoachSource.cloud));
  }
}

void main() {
  const full = CoachContext(
    name: 'Amrut',
    goal: 'Lose weight',
    age: 27,
    weightKg: 78.4,
    heightCm: 175,
    calorieGoal: 2100,
    proteinGoal: 140,
    carbsGoal: 220,
    fatGoal: 60,
    stepsToday: 6400,
    stepGoal: 10000,
    streakDays: 5,
    waterTodayMl: 1500,
    waterGoalMl: 2750,
    weekWeightChangeKg: -0.6,
    weekMacroAdherencePct: 82,
    weekLoggedDays: 3,
    weekDaysElapsed: 4,
    weekWorkouts: 2,
    weekWorkoutMinutes: 75,
    weekWaterDaysMet: 1,
  );

  group('CoachPromptBuilder.contextFacts', () {
    test('lists known facts with units', () {
      final facts = CoachPromptBuilder.contextFacts(full);
      expect(facts, contains('Weight: 78.4 kg'));
      expect(facts, contains('BMI: 25.6'));
      expect(facts, contains('Steps today: 6400 of 10000'));
      expect(facts, contains('Water today: 1500 ml of 2750 ml'));
      expect(facts, contains('Weight change vs last week: -0.6 kg'));
      expect(
        facts,
        contains('Macro adherence this week: 82% (3 of 4 days logged)'),
      );
      expect(facts, contains('Workouts this week: 2 (75 min)'));
      expect(
        facts,
        contains('Macro goals: protein 140 g, carbs 220 g, fat 60 g'),
      );
    });

    test('skips missing and zero values', () {
      final facts = CoachPromptBuilder.contextFacts(
        const CoachContext(weightKg: 0, calorieGoal: 0, goal: ''),
      );
      expect(facts, isEmpty);
    });

    test('positive weight change has a plus sign', () {
      final facts = CoachPromptBuilder.contextFacts(
        const CoachContext(weekWeightChangeKg: 0.25),
      );
      expect(facts.single, 'Weight change vs last week: +0.3 kg');
    });
  });

  group('CoachPromptBuilder.build', () {
    const builder = CoachPromptBuilder(maxHistoryTurns: 2, maxTurnChars: 20);

    test('data, recent history and the question, in that order', () {
      final prompt = builder.build(
        question: '  What next? ',
        context: const CoachContext(streakDays: 3),
        history: const [
          CoachMessage.user('first question'),
          CoachMessage(role: CoachRole.coach, text: 'first answer'),
          CoachMessage.user('second question'),
          CoachMessage(
            role: CoachRole.coach,
            text: 'Could not answer',
            failed: true,
          ),
          CoachMessage(
            role: CoachRole.coach,
            text: 'a very long answer that goes on and on',
          ),
        ],
      );

      expect(
        prompt,
        'User data:\n'
        '- Workout streak: 3 days\n'
        '\n'
        'Conversation so far:\n'
        'User: second question\n'
        'Coach: a very long answer t…\n'
        '\n'
        'User question: What next?',
      );
    });

    test('no data and no history is just the question', () {
      expect(
        builder.build(question: 'Hi', context: const CoachContext()),
        'User question: Hi',
      );
    });

    test('asks for a reply in the app language, except English', () {
      expect(
        builder.build(
          question: 'Hi',
          context: const CoachContext(),
          language: 'Marathi',
        ),
        startsWith('User question: Hi\n\nReply in Marathi'),
      );
      expect(
        builder.build(
          question: 'Hi',
          context: const CoachContext(),
          language: 'English',
        ),
        'User question: Hi',
      );
    });
  });

  group('AskCoach.localized', () {
    test('passes the language into the prompt', () async {
      final repo = _Repo();
      final ask = AskCoach.localized(
        repo,
        language: () => 'Hindi',
        cannedText: (_) => 'canned',
      );
      await ask(
        question: 'Protein?',
        context: const CoachContext(),
      ).drain<void>();
      expect(repo.prompts.single, contains('Reply in Hindi'));
    });

    test('safety replies come from cannedText, not the model', () async {
      final repo = _Repo();
      final ask = AskCoach.localized(
        repo,
        language: () => 'Hindi',
        cannedText: (k) => 'canned:${k.name}',
      );
      final d = await ask(
        question: 'मुझे सीने में दर्द है',
        context: const CoachContext(),
      ).single;
      expect(d.text, 'canned:emergency');
      expect(d.source, CoachSource.rule);
      expect(repo.prompts, isEmpty);
    });
  });

  group('CoachSafety', () {
    test('emergencies get the emergency reply', () {
      expect(
        CoachSafety.cannedReply('I have chest pain after running'),
        CoachSafety.emergencyReply,
      );
      expect(
        CoachSafety.cannedReply('I fainted at the gym'),
        CoachSafety.emergencyReply,
      );
    });

    test('Hindi and Marathi emergencies are caught too', () {
      for (final q in [
        'दौड़ने के बाद सीने में दर्द हो रहा है',
        'व्यायामानंतर छातीत दुखत आहे',
        'जिम में बेहोश हो गया',
      ]) {
        expect(CoachSafety.classify(q), CannedReply.emergency, reason: q);
      }
    });

    test('professional topics are referred', () {
      expect(
        CoachSafety.cannedReply('Which steroids help bulking?'),
        CoachSafety.professionalReply,
      );
      expect(
        CoachSafety.cannedReply('Is it ok to starve for a week?'),
        CoachSafety.professionalReply,
      );
    });

    test('normal questions go to the model', () {
      expect(
        CoachSafety.cannedReply('How much protein after a workout?'),
        isNull,
      );
      expect(CoachSafety.cannedReply('Plan my leg day'), isNull);
    });
  });
}
