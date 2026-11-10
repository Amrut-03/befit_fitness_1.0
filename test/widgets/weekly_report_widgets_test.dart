import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/features/progress_report/domain/entities/weekly_report.dart';
import 'package:fitness_app/features/progress_report/presentation/bloc/weekly_report_bloc.dart';
import 'package:fitness_app/features/progress_report/presentation/pages/weekly_report_page.dart';
import 'package:fitness_app/features/progress_report/presentation/widgets/weekly_report_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'pump_app.dart';

class _Report extends MockBloc<WeeklyReportEvent, WeeklyReportState>
    implements WeeklyReportBloc {}

void main() {
  setUpAll(() => registerFallbackValue(const WeeklyReportRefreshed()));

  final now = DateTime(2026, 11, 12);
  final week = WeekRange.of(now);
  late _Report bloc;

  const goals = MacroGoals(protein: 150, carbs: 200, fat: 60, calories: 2000);

  WeeklyReport full() => WeeklyReport(
    week: week,
    daysElapsed: 4,
    weightTrend: [
      WeeklyWeight(weekStart: week.shift(-2).start, avgKg: 72.4),
      WeeklyWeight(weekStart: week.shift(-1).start, avgKg: 71.9),
      WeeklyWeight(weekStart: week.start, avgKg: 71.5),
    ],
    weightChangeKg: -0.4,
    latestWeightKg: 71.3,
    macroDays: [
      for (final d in week.days)
        d.day <= 11
            ? MacroDay(
                day: d,
                logged: true,
                protein: 140,
                carbs: 210,
                fat: 55,
                calories: 1950,
              )
            : MacroDay(day: d),
    ],
    goals: goals,
    adherencePct: 93,
    workouts: 2,
    workoutSets: 18,
    workoutMinutes: 75,
    waterDaysMet: 3,
  );

  setUp(() => bloc = _Report());

  Future<void> pump(WidgetTester t, WeeklyReportState state, Widget w) {
    when(() => bloc.state).thenReturn(state);
    return t.pumpApp(
      BlocProvider<WeeklyReportBloc>.value(value: bloc, child: w),
    );
  }

  group('WeeklyReportCard', () {
    testWidgets('shows tiles and both charts', (t) async {
      await pump(
        t,
        WeeklyReportState(status: ReportStatus.ready, report: full()),
        const SingleChildScrollView(child: WeeklyReportCard()),
      );

      expect(find.text('Weekly progress'), findsOneWidget);
      expect(find.text('−0.4 kg'), findsOneWidget);
      expect(find.text('93%'), findsOneWidget);
      expect(find.text('logged 3/4 days'), findsOneWidget);
      expect(find.text('18 sets · 75 min'), findsOneWidget);
      expect(find.text('3/4'), findsOneWidget);
      expect(find.text('Weight trend'), findsOneWidget);
      expect(find.text('Macro adherence'), findsOneWidget);
    });

    testWidgets('requests the report on first build', (t) async {
      await pump(
        t,
        const WeeklyReportState(),
        const SingleChildScrollView(child: WeeklyReportCard()),
      );

      verify(() => bloc.add(const WeeklyReportRequested())).called(1);
    });

    testWidgets('empty week explains how to get data', (t) async {
      await pump(
        t,
        WeeklyReportState(
          status: ReportStatus.ready,
          report: WeeklyReport(
            week: week,
            daysElapsed: 4,
            macroDays: [for (final d in week.days) MacroDay(day: d)],
            goals: goals,
          ),
        ),
        const SingleChildScrollView(child: WeeklyReportCard()),
      );

      expect(find.text('Log your weight to see the trend.'), findsOneWidget);
      expect(
        find.text('Tick off meals in your diet plan to see your macros.'),
        findsOneWidget,
      );
      expect(find.text('—'), findsNWidgets(2)); // weight, macros
    });
  });

  group('WeeklyReportPage', () {
    testWidgets('week switcher pages back; next is off for this week', (
      t,
    ) async {
      await pump(
        t,
        WeeklyReportState(status: ReportStatus.ready, report: full()),
        WeeklyReportPage(clock: () => now),
      );

      expect(find.text('This week'), findsOneWidget);
      expect(find.text('9 – 15 Nov'), findsOneWidget);
      final next = t.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(next.onPressed, isNull);

      await t.tap(find.byTooltip('Previous week'));
      verify(() => bloc.add(const WeeklyReportRequested(1))).called(1);
    });

    testWidgets('shows the daily macro table for logged days', (t) async {
      await pump(
        t,
        WeeklyReportState(status: ReportStatus.ready, report: full()),
        WeeklyReportPage(clock: () => now),
      );

      expect(find.text('Score'), findsOneWidget);
      expect(find.text('Goal'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsNothing); // not logged
    });
  });
}
