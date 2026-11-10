import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/features/water_intake/domain/entities/water_day.dart';
import 'package:fitness_app/features/water_intake/domain/entities/water_entry.dart';
import 'package:fitness_app/features/water_intake/presentation/bloc/water_intake_bloc.dart';
import 'package:fitness_app/features/water_intake/presentation/pages/water_intake_page.dart';
import 'package:fitness_app/features/water_intake/presentation/widgets/water_intake_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'pump_app.dart';

class _Water extends MockBloc<WaterIntakeEvent, WaterIntakeState>
    implements WaterIntakeBloc {}

void main() {
  setUpAll(() => registerFallbackValue(const WaterIntakeRefreshed()));

  late _Water bloc;
  final day = DateTime(2026, 11, 10);

  WaterIntakeState ready(List<int> amounts, {int goal = 2000}) {
    final entries = [
      for (var i = 0; i < amounts.length; i++)
        WaterEntry(
          id: '$i',
          ml: amounts[i],
          at: day.add(Duration(hours: 8 + i)),
        ),
    ];
    final today = WaterDay(day: day, goalMl: goal, entries: entries);
    return WaterIntakeState(
      status: WaterStatus.ready,
      today: today,
      goalMl: goal,
      recommendedGoalMl: 2450,
      history: [
        for (var i = 6; i > 0; i--)
          WaterDay(
            day: day.subtract(Duration(days: i)),
            goalMl: goal,
          ),
        today,
      ],
    );
  }

  setUp(() => bloc = _Water());

  Future<void> pump(WidgetTester t, WaterIntakeState state, Widget child) {
    when(() => bloc.state).thenReturn(state);
    return t.pumpApp(
      BlocProvider<WaterIntakeBloc>.value(value: bloc, child: child),
    );
  }

  group('WaterIntakePage', () {
    testWidgets('shows progress, the log and the week', (t) async {
      await pump(t, ready([250, 300]), const WaterIntakePage());
      await t.pumpAndSettle();

      expect(find.text('550 ml'), findsOneWidget);
      expect(find.text('of 2 L'), findsOneWidget);
      expect(find.text('1.45 L to go'), findsOneWidget);
      expect(find.text('Last 7 days'), findsOneWidget);
      expect(find.byType(Dismissible), findsNWidgets(2));
    });

    testWidgets('a quick-add chip logs that amount', (t) async {
      await pump(t, ready([]), const WaterIntakePage());
      await t.pumpAndSettle();

      expect(find.text('Nothing logged yet. Tap an amount above.'), findsOne);
      await t.tap(find.widgetWithText(ActionChip, '500 ml'));

      verify(() => bloc.add(const WaterAdded(500))).called(1);
    });

    testWidgets('swiping an entry removes it', (t) async {
      await pump(t, ready([250]), const WaterIntakePage());
      await t.pumpAndSettle();

      await t.drag(find.byType(Dismissible), const Offset(-600, 0));
      await t.pumpAndSettle();

      verify(() => bloc.add(any(that: isA<WaterEntryRemoved>()))).called(1);
    });
  });

  group('WaterIntakeCard', () {
    testWidgets('starts the bloc and logs with one tap', (t) async {
      await pump(
        t,
        const WaterIntakeState(),
        const Scaffold(body: WaterIntakeCard()),
      );

      verify(() => bloc.add(const WaterIntakeStarted())).called(1);
      await t.tap(find.text('250 ml'));
      verify(() => bloc.add(const WaterAdded(250))).called(1);
    });

    testWidgets('celebrates a met goal', (t) async {
      await pump(
        t,
        ready([1500, 600]),
        const Scaffold(body: WaterIntakeCard()),
      );

      expect(find.text('2.1 L / 2 L'), findsOneWidget);
      expect(find.text('Goal reached 🎉'), findsOneWidget);
    });
  });
}
