import 'dart:io';

import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/local/ai_insights_local_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/datasources/remote/ai_insights_remote_datasource.dart';
import 'package:fitness_app/features/ai_insights/data/models/ai_insight_model.dart';
import 'package:fitness_app/features/ai_insights/data/repositories/ai_insights_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

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
  var now = DateTime(2026, 11, 10, 9);
  String? uid = 'alice';

  AIInsightsRepositoryImpl repo() => AIInsightsRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: AIInsightsLocalDatasource(box),
    currentUid: () => uid,
    now: () => now,
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
    now = DateTime(2026, 11, 10, 9);
    uid = 'alice';
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
}
