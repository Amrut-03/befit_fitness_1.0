import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:fitness_app/features/water_intake/domain/entities/water_day.dart';
import 'package:fitness_app/features/water_intake/domain/entities/water_entry.dart';
import 'package:fitness_app/features/water_intake/domain/repositories/hydration_reminders.dart';
import 'package:fitness_app/features/water_intake/domain/repositories/water_intake_repository.dart';
import 'package:fitness_app/features/water_intake/domain/usecases/water_usecases.dart';
import 'package:fitness_app/features/water_intake/presentation/bloc/water_intake_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// In-memory repository whose day streams behave like Firestore snapshots.
class _Repo implements WaterIntakeRepository {
  _Repo({this.now});

  DateTime Function()? now;
  int? savedGoal;
  int recommended = 2450;
  final _entries = <DateTime, List<WaterEntry>>{};
  final _controllers = <DateTime, StreamController<WaterDay>>{};
  final watched = <DateTime>[];
  Object? failAdd;

  DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  WaterDay _snapshot(DateTime day, int goal) =>
      WaterDay(day: day, goalMl: goal, entries: [...?_entries[day]]);

  void _emit(DateTime day) =>
      _controllers[day]?.add(_snapshot(day, savedGoal ?? recommended));

  @override
  Stream<WaterDay> watchDay(DateTime day, {required int goalMl}) {
    watched.add(day);
    final c = _controllers[day] ??= StreamController<WaterDay>.broadcast();
    scheduleMicrotask(() => c.add(_snapshot(day, goalMl)));
    return c.stream;
  }

  @override
  Future<List<WaterDay>> getHistory({
    required int days,
    required int goalMl,
  }) async {
    final today = _dayOf(now!());
    return [
      for (var i = days - 1; i >= 0; i--)
        _snapshot(DateTime(today.year, today.month, today.day - i), goalMl),
    ];
  }

  @override
  Future<List<WaterDay>> getRange(
    DateTime from, {
    required int days,
    required int goalMl,
  }) async => [
    for (var i = 0; i < days; i++)
      _snapshot(DateTime(from.year, from.month, from.day + i), goalMl),
  ];

  @override
  Future<void> addEntry(int ml, {required int goalMl}) async {
    if (failAdd != null) throw failAdd!;
    final t = now!();
    final day = _dayOf(t);
    (_entries[day] ??= []).add(
      WaterEntry(id: '${t.microsecondsSinceEpoch}$ml', ml: ml, at: t),
    );
    _emit(day);
  }

  @override
  Future<void> removeEntry(DateTime day, WaterEntry entry) async {
    _entries[day]?.remove(entry);
    _emit(day);
  }

  @override
  Future<int> getGoalMl() async => savedGoal ?? recommended;

  @override
  Future<int> getRecommendedGoalMl() async => recommended;

  @override
  Future<void> setGoalMl(int ml) async => savedGoal = ml;
}

class _Reminders extends Mock implements HydrationReminders {}

class _Analytics extends Mock implements AppAnalytics {}

void main() {
  late _Repo repo;
  late _Reminders reminders;
  late _Analytics analytics;
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 11, 10, 9);
    repo = _Repo(now: () => now)..savedGoal = 1000;
    reminders = _Reminders();
    analytics = _Analytics();
    when(() => reminders.goalReachedToday()).thenAnswer((_) async {});
    when(() => reminders.goalNotReachedToday()).thenAnswer((_) async {});
    when(
      () => analytics.logWaterLogged(ml: any(named: 'ml')),
    ).thenAnswer((_) async {});
  });

  WaterIntakeBloc build() => WaterIntakeBloc(
    watchDay: WatchWaterDay(repo),
    getHistory: GetWaterHistory(repo),
    addWater: AddWater(repo),
    removeWater: RemoveWater(repo),
    getGoal: GetWaterGoal(repo),
    getRecommendedGoal: GetRecommendedWaterGoal(repo),
    setGoal: SetWaterGoal(repo),
    reminders: reminders,
    analytics: analytics,
    clock: () => now,
  );

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('start loads goal, recommendation, 7-day history and today', () async {
    final bloc = build()..add(const WaterIntakeStarted());
    await settle();

    expect(bloc.state.status, WaterStatus.ready);
    expect(bloc.state.goalMl, 1000);
    expect(bloc.state.recommendedGoalMl, 2450);
    expect(bloc.state.history, hasLength(7));
    expect(bloc.state.today!.day, DateTime(2026, 11, 10));
    expect(bloc.state.totalMl, 0);
    await bloc.close();
  });

  test('adding updates today and logs analytics', () async {
    final bloc = build()..add(const WaterIntakeStarted());
    await settle();

    bloc.add(const WaterAdded(250));
    await settle();

    expect(bloc.state.totalMl, 250);
    expect(bloc.state.week.last.totalMl, 250);
    verify(() => analytics.logWaterLogged(ml: 250)).called(1);
    verifyNever(() => reminders.goalReachedToday());
    await bloc.close();
  });

  test('crossing the goal quiets reminders once; undo restores them', () async {
    final bloc = build()..add(const WaterIntakeStarted());
    await settle();

    bloc
      ..add(const WaterAdded(500))
      ..add(const WaterAdded(500));
    await settle();
    expect(bloc.state.today!.goalReached, isTrue);
    verify(() => reminders.goalReachedToday()).called(1);

    bloc.add(const WaterAdded(250)); // still over: no second call
    await settle();
    verifyNever(() => reminders.goalReachedToday());

    final last = bloc.state.today!.entries.last;
    final first = bloc.state.today!.entries.first;
    bloc.add(WaterEntryRemoved(last));
    await settle();
    verifyNever(() => reminders.goalNotReachedToday()); // 1000 ≥ goal

    bloc.add(WaterEntryRemoved(first));
    await settle();
    expect(bloc.state.totalMl, 500);
    verify(() => reminders.goalNotReachedToday()).called(1);
    await bloc.close();
  });

  test('raising the goal re-measures today and saves it', () async {
    final bloc = build()..add(const WaterIntakeStarted());
    await settle();
    bloc.add(const WaterAdded(1000));
    await settle();
    verify(() => reminders.goalReachedToday()).called(1);

    bloc.add(const WaterGoalUpdated(3000));
    await settle();

    expect(bloc.state.goalMl, 3000);
    expect(bloc.state.today!.goalMl, 3000);
    expect(bloc.state.today!.goalReached, isFalse);
    expect(repo.savedGoal, 3000);
    verify(() => reminders.goalNotReachedToday()).called(1);
    await bloc.close();
  });

  test('refresh after midnight moves to the new day', () async {
    final bloc = build()..add(const WaterIntakeStarted());
    await settle();
    bloc.add(const WaterAdded(750));
    await settle();

    now = DateTime(2026, 11, 11, 0, 5);
    bloc.add(const WaterIntakeRefreshed());
    await settle();

    expect(repo.watched.last, DateTime(2026, 11, 11));
    expect(bloc.state.today!.day, DateTime(2026, 11, 11));
    expect(bloc.state.totalMl, 0);
    expect(bloc.state.week[5].totalMl, 750); // yesterday kept in history
    await bloc.close();
  });

  test('a failed write surfaces a one-off message', () async {
    final bloc = build()..add(const WaterIntakeStarted());
    await settle();
    repo.failAdd = Exception('offline');

    bloc.add(const WaterAdded(250));
    await settle();

    expect(bloc.state.message, isNotNull);
    expect(bloc.state.totalMl, 0);
    await bloc.close();
  });

  blocTest<WaterIntakeBloc, WaterIntakeState>(
    'rejects amounts outside 1–3000 ml',
    build: build,
    act: (bloc) => bloc.add(const WaterAdded(5000)),
    expect: () => [
      isA<WaterIntakeState>().having(
        (s) => s.message,
        'message',
        contains('between 1 and 3000'),
      ),
    ],
  );
}
