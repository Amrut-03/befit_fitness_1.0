import 'dart:io';

import 'package:fitness_app/core/ai/on_device_llm.dart';
import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/local/ai_insights_local_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/on_device/ai_insights_on_device_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/remote/ai_insights_remote_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/models/ai_insight_model.dart';
import 'package:fitness_app/features/ai_insights/data/repositories/ai_insights_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../ai_coach/fake_on_device_llm.dart';

class _Remote extends Fake implements AIInsightsRemoteDatasource {
  int calls = 0;

  @override
  Future<List<AIInsightModel>> generateInsights({
    required int steps,
    required int calories,
    required int streak,
    required double bmi,
  }) async {
    calls++;
    return [
      AIInsightModel(
        title: 'Call $calls',
        message: 'Steps $steps',
        emoji: '🔥',
      ),
    ];
  }
}

void main() {
  late Directory dir;
  late Box<dynamic> box;
  late _Remote remote;
  late FakeOnDeviceLlm llm;
  var now = DateTime(2026, 11, 10, 9);
  String? uid = 'alice';
  var lang = 'en';

  AIInsightsRepositoryImpl repo() => AIInsightsRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: AIInsightsLocalDatasource(box),
    onDeviceDatasource: AIInsightsOnDeviceDatasource(llm),
    currentUid: () => uid,
    now: () => now,
    languageCode: () => lang,
  );

  Future<String> title() async => (await repo().getDailyInsights(
    steps: 100,
    calories: 10,
    streak: 1,
    bmi: 22,
  )).first.title;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hive_ai');
    Hive.init(dir.path);
    box = await Hive.openBox('ai_${DateTime.now().microsecondsSinceEpoch}');
    remote = _Remote();
    llm = FakeOnDeviceLlm();
    now = DateTime(2026, 11, 10, 9);
    uid = 'alice';
    lang = 'en';
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('generates once per day, then serves the cache', () async {
    expect(await title(), 'Call 1');
    now = DateTime(2026, 11, 10, 22);
    expect(await title(), 'Call 1');
    expect(remote.calls, 1);
  });

  test('a new day regenerates', () async {
    await title();
    now = DateTime(2026, 11, 11, 7);
    expect(await title(), 'Call 2');
  });

  test("another user doesn't get the previous user's cache", () async {
    await title();
    uid = 'bob';
    expect(await title(), 'Call 2');
  });

  test('switching language regenerates instead of serving the cache', () async {
    await title();
    lang = 'hi';
    expect(await title(), 'Call 2');
    expect(await title(), 'Call 2', reason: 'Hindi insights are cached too');
    lang = 'en';
    expect(await title(), 'Call 3');
  });

  test('asks for the text in the app language, JSON keys in English', () {
    expect(AIInsightsRemoteDatasource.languageInstruction('English'), isEmpty);
    expect(
      AIInsightsRemoteDatasource.languageInstruction('Hindi'),
      allOf(contains('in Hindi'), contains('JSON keys in English')),
    );
  });

  test('forceRefresh bypasses the cache', () async {
    await title();
    final r = await repo().getDailyInsights(
      steps: 1,
      calories: 1,
      streak: 1,
      bmi: 22,
      forceRefresh: true,
    );
    expect(r.first.title, 'Call 2');
  });

  test('signed out → UnauthenticatedException', () {
    uid = null;
    expect(title(), throwsA(isA<UnauthenticatedException>()));
  });
  group('on-device', () {
    const json =
        '[{"emoji":"🚶","title":"Keep moving","message":"Steps on device."},'
        '{"emoji":"💧","title":"Hydrate","message":"Drink water."}]';

    test('used first when the model is ready, and cached', () async {
      llm
        ..current = OnDeviceModelStatus.ready
        ..tokens = ['Sure! ```json\n', json, '\n```'];

      expect(await title(), 'Keep moving');
      expect(await title(), 'Keep moving');
      expect(remote.calls, 0);
      expect(llm.prompts.single, contains('Steps: 100'));
    });

    test('falls back to Gemini when on-device output is unusable', () async {
      llm
        ..current = OnDeviceModelStatus.ready
        ..tokens = ['I cannot help with that.'];

      expect(await title(), 'Call 1');
    });

    test('falls back to Gemini when on-device throws', () async {
      llm
        ..current = OnDeviceModelStatus.ready
        ..generateError = const OnDeviceLlmUnavailable('engine');

      expect(await title(), 'Call 1');
    });

    test('not used when the model is not downloaded', () async {
      expect(await title(), 'Call 1');
      expect(llm.prompts, isEmpty);
    });
  });
}
