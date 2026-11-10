import 'dart:async';

import 'package:fitness_app/core/ai/on_device_llm.dart';
import 'package:fitness_app/features/ai_coach/data/datasources/coach_cloud_datasource.dart';
import 'package:fitness_app/features/ai_coach/data/repositories/coach_repository_impl.dart';
import 'package:fitness_app/features/ai_coach/domain/entities/coach_delta.dart';
import 'package:fitness_app/features/ai_coach/domain/entities/coach_message.dart';
import 'package:fitness_app/features/ai_coach/domain/services/coach_prompt_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_on_device_llm.dart';

void main() {
  late FakeOnDeviceLlm llm;
  late List<String> cloudPrompts;

  CoachRepositoryImpl repo({List<String> cloud = const ['Cloud ', 'answer']}) =>
      CoachRepositoryImpl(
        onDevice: llm,
        cloud: CoachCloudDatasource((p) {
          cloudPrompts.add(p);
          return Stream.fromIterable([...cloud, '']);
        }),
      );

  setUp(() {
    llm = FakeOnDeviceLlm();
    cloudPrompts = [];
  });

  test('uses the on-device model when it is ready', () async {
    llm
      ..current = OnDeviceModelStatus.ready
      ..tokens = ['Hi', ' there'];

    final out = await repo().reply('prompt').toList();

    expect(out, const [
      CoachDelta('Hi', CoachSource.onDevice),
      CoachDelta(' there', CoachSource.onDevice),
    ]);
    expect(llm.systemInstructions.single, CoachPromptBuilder.systemInstruction);
    expect(cloudPrompts, isEmpty);
  });

  test('uses the cloud when the model is not downloaded', () async {
    final out = await repo().reply('prompt').toList();

    expect(out.map((d) => d.source).toSet(), {CoachSource.cloud});
    expect(out.map((d) => d.text).join(), 'Cloud answer');
    expect(llm.prompts, isEmpty);
    expect(cloudPrompts, ['prompt']);
  });

  test('falls back to the cloud when on-device fails to start', () async {
    llm
      ..current = OnDeviceModelStatus.ready
      ..generateError = const OnDeviceLlmUnavailable('engine');

    final out = await repo().reply('prompt').toList();

    expect(out.map((d) => d.text).join(), 'Cloud answer');
  });

  test('falls back when on-device produces nothing', () async {
    llm.current = OnDeviceModelStatus.ready;

    final out = await repo().reply('prompt').toList();

    expect(out.map((d) => d.text).join(), 'Cloud answer');
  });

  test('a failure mid-answer surfaces instead of switching models', () async {
    llm
      ..current = OnDeviceModelStatus.ready
      ..tokens = ['Partial']
      ..streamError = StateError('boom');

    final received = <CoachDelta>[];
    await expectLater(
      repo().reply('prompt').forEach(received.add),
      throwsStateError,
    );
    expect(received, const [CoachDelta('Partial', CoachSource.onDevice)]);
    expect(cloudPrompts, isEmpty);
  });
}
