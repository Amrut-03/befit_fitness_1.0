import 'package:fitness_app/features/ai_coach/domain/entities/coach_context.dart';
import 'package:fitness_app/features/ai_coach/domain/entities/coach_message.dart';
import 'package:fitness_app/features/ai_coach/domain/services/coach_prompt_builder.dart';
import 'package:fitness_app/features/ai_coach/domain/services/coach_safety.dart';
import 'package:flutter_test/flutter_test.dart';

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
