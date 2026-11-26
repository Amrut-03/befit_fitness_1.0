import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/features/ai_coach/domain/entities/coach_context.dart';
import 'package:fitness_app/features/ai_coach/domain/entities/coach_delta.dart';
import 'package:fitness_app/features/ai_coach/domain/entities/coach_message.dart';
import 'package:fitness_app/features/ai_coach/domain/repositories/coach_repository.dart';
import 'package:fitness_app/features/ai_coach/domain/services/coach_safety.dart';
import 'package:fitness_app/features/ai_coach/domain/usecases/ask_coach.dart';
import 'package:fitness_app/features/ai_coach/presentation/bloc/coach_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements CoachRepository {
  Stream<CoachDelta> Function(String prompt) reply_ = (_) =>
      const Stream.empty();
  final prompts = <String>[];

  @override
  Stream<CoachDelta> reply(String prompt) {
    prompts.add(prompt);
    return reply_(prompt);
  }
}

void main() {
  late _Repo repo;
  const ctx = CoachContext(streakDays: 4);

  setUp(() => repo = _Repo());

  CoachBloc build() => CoachBloc(AskCoach(repo));

  CoachMessage coach(String text, {CoachSource? source, bool failed = false}) =>
      CoachMessage(
        role: CoachRole.coach,
        text: text,
        source: source,
        failed: failed,
      );

  blocTest<CoachBloc, CoachState>(
    'streams the answer into the last message',
    setUp: () => repo.reply_ = (_) => Stream.fromIterable(const [
      CoachDelta('Walk ', CoachSource.onDevice),
      CoachDelta('more.', CoachSource.onDevice),
    ]),
    build: build,
    act: (b) => b.add(const CoachQuestionSubmitted('  Tips? ', ctx)),
    expect: () => [
      CoachState(
        messages: [const CoachMessage.user('Tips?'), coach('')],
        generating: true,
      ),
      CoachState(
        messages: [
          const CoachMessage.user('Tips?'),
          coach('Walk ', source: CoachSource.onDevice),
        ],
        generating: true,
      ),
      CoachState(
        messages: [
          const CoachMessage.user('Tips?'),
          coach('Walk more.', source: CoachSource.onDevice),
        ],
        generating: true,
      ),
      CoachState(
        messages: [
          const CoachMessage.user('Tips?'),
          coach('Walk more.', source: CoachSource.onDevice),
        ],
      ),
    ],
    verify: (_) => expect(repo.prompts.single, contains('Workout streak: 4')),
  );

  blocTest<CoachBloc, CoachState>(
    'blank questions are ignored',
    build: build,
    act: (b) => b.add(const CoachQuestionSubmitted('   ', ctx)),
    expect: () => const <CoachState>[],
  );

  blocTest<CoachBloc, CoachState>(
    'safety replies skip the model',
    build: build,
    act: (b) => b.add(const CoachQuestionSubmitted('I have chest pain', ctx)),
    skip: 2,
    expect: () => [
      CoachState(
        messages: [
          const CoachMessage.user('I have chest pain'),
          coach(CoachSafety.emergencyReply, source: CoachSource.rule),
        ],
      ),
    ],
    verify: (_) => expect(repo.prompts, isEmpty),
  );

  blocTest<CoachBloc, CoachState>(
    'offline with no model explains how to chat offline',
    setUp: () =>
        repo.reply_ = (_) =>
            Stream.error(const SocketException('Failed host lookup')),
    build: build,
    act: (b) => b.add(const CoachQuestionSubmitted('Hi', ctx)),
    skip: 1,
    expect: () => [
      CoachState(
        messages: [
          const CoachMessage.user('Hi'),
          coach(CoachBloc.offlineMessage, failed: true),
        ],
      ),
    ],
  );

  blocTest<CoachBloc, CoachState>(
    'an empty answer is reported',
    build: build,
    act: (b) => b.add(const CoachQuestionSubmitted('Hi', ctx)),
    skip: 1,
    expect: () => [
      CoachState(
        messages: [
          const CoachMessage.user('Hi'),
          coach(CoachBloc.emptyMessage, failed: true),
        ],
      ),
    ],
  );

  test('history from earlier turns is sent with the next question', () async {
    repo.reply_ = (_) =>
        Stream.value(const CoachDelta('Drink water.', CoachSource.cloud));
    final bloc = build()..add(const CoachQuestionSubmitted('First', ctx));
    await bloc.stream.firstWhere((s) => !s.generating && s.messages.isNotEmpty);
    bloc.add(const CoachQuestionSubmitted('Second', ctx));
    await bloc.stream.firstWhere(
      (s) => !s.generating && s.messages.length == 4,
    );

    expect(repo.prompts.last, contains('User: First'));
    expect(repo.prompts.last, contains('Coach: Drink water.'));
    await bloc.close();
  });

  test('stop keeps the partial answer and cancels the stream', () async {
    final controller = StreamController<CoachDelta>();
    var cancelled = false;
    controller.onCancel = () => cancelled = true;
    repo.reply_ = (_) => controller.stream;

    final bloc = build()..add(const CoachQuestionSubmitted('Hi', ctx));
    await bloc.stream.firstWhere((s) => s.generating);
    controller.add(const CoachDelta('Half', CoachSource.onDevice));
    await bloc.stream.firstWhere((s) => s.messages.last.text == 'Half');

    // A second question while generating is ignored.
    bloc
      ..add(const CoachQuestionSubmitted('Another', ctx))
      ..add(const CoachStopRequested());
    final done = await bloc.stream.firstWhere((s) => !s.generating);

    expect(done.messages, [
      const CoachMessage.user('Hi'),
      coach('Half', source: CoachSource.onDevice),
    ]);
    expect(cancelled, isTrue);
    await bloc.close();
  });

  test('clear empties the chat', () async {
    repo.reply_ = (_) =>
        Stream.value(const CoachDelta('Ok', CoachSource.cloud));
    final bloc = build()..add(const CoachQuestionSubmitted('Hi', ctx));
    await bloc.stream.firstWhere((s) => !s.generating && s.messages.isNotEmpty);
    bloc.add(const CoachCleared());
    await bloc.stream.firstWhere((s) => s.messages.isEmpty);
    await bloc.close();
  });
}
