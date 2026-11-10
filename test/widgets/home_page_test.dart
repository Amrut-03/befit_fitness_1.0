import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/ai_insights/presentation/bloc/ai_insights_bloc.dart';
import 'package:fitness_app/features/body_part_selection/presentation/bloc/body_part_selection_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_event.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_state.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_event.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_state.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_bloc.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_event.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_state.dart';
import 'package:fitness_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:fitness_app/features/home/presentation/pages/home_page.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_event.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_state.dart';
import 'package:fitness_app/features/water_intake/presentation/bloc/water_intake_bloc.dart';
import 'package:fitness_app/features/water_intake/presentation/widgets/water_intake_card.dart';
import 'package:fitness_app/features/workout/presentation/cubit/workout_session_cubit.dart';
import 'package:fitness_app/features/progress_report/presentation/bloc/weekly_report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'a11y.dart';
import 'pump_app.dart';

class _Home extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class _Profile extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class _Diet extends MockBloc<DietEvent, DietState> implements DietBloc {}

class _Health extends MockBloc<HealthEvent, HealthState>
    implements HealthBloc {}

class _Streak extends MockBloc<StreakEvent, StreakState>
    implements StreakBloc {}

class _Insights extends MockBloc<AIInsightsEvent, AIInsightsState>
    implements AIInsightsBloc {}

class _Metrics extends MockBloc<HealthMetricEvent, HealthMetricState>
    implements HealthMetricsBloc {}

class _Water extends MockBloc<WaterIntakeEvent, WaterIntakeState>
    implements WaterIntakeBloc {}

class _Session extends MockCubit<WorkoutSessionState>
    implements WorkoutSessionCubit {}

class _Report extends MockBloc<WeeklyReportEvent, WeeklyReportState>
    implements WeeklyReportBloc {}

void main() {
  late _Home home;

  setUp(() {
    home = _Home();
    final sl = GetIt.instance;
    sl.registerFactory<BodySelectionBloc>(BodySelectionBloc.new);
    sl.registerFactory<HealthMetricsBloc>(() {
      final metrics = _Metrics();
      when(() => metrics.state).thenReturn(HealthMetricLoading());
      return metrics;
    });
  });

  tearDown(() => GetIt.instance.reset());

  Future<void> pump(
    WidgetTester tester,
    HomeState state, {
    Locale locale = const Locale('en'),
  }) async {
    when(() => home.state).thenReturn(state);

    final profile = _Profile();
    when(() => profile.state).thenReturn(ProfileInitial());
    final diet = _Diet();
    when(() => diet.state).thenReturn(DietState.initial());
    final health = _Health();
    when(() => health.state).thenReturn(HealthInitial());
    final streak = _Streak();
    when(() => streak.state).thenReturn(StreakState.initial());
    final insights = _Insights();
    when(() => insights.state).thenReturn(AIInsightsInitial());
    final session = _Session();
    when(() => session.state).thenReturn(const WorkoutSessionState());
    final report = _Report();
    when(() => report.state).thenReturn(const WeeklyReportState());
    final water = _Water();
    when(() => water.state).thenReturn(const WaterIntakeState());

    await tester.pumpApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>.value(value: home),
          BlocProvider<ProfileBloc>.value(value: profile),
          BlocProvider<DietBloc>.value(value: diet),
          BlocProvider<HealthBloc>.value(value: health),
          BlocProvider<StreakBloc>.value(value: streak),
          BlocProvider<AIInsightsBloc>.value(value: insights),
          BlocProvider<WaterIntakeBloc>.value(value: water),
          BlocProvider<WeeklyReportBloc>.value(value: report),
          BlocProvider<WorkoutSessionCubit>.value(value: session),
        ],
        child: const HomePage(),
      ),
      locale: locale,
    );
    await tester.pumpForLoaders();
  }

  testWidgets('loading shows the loader only', (tester) async {
    await pump(tester, HomeLoading());

    expect(find.byType(AppLoader), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsNothing);
  });

  testWidgets('error shows the message', (tester) async {
    await pump(tester, const HomeError(message: 'Could not load dashboard'));

    expect(find.text('Could not load dashboard'), findsOneWidget);
  });

  testWidgets('loaded shows the greeting and dashboard sections', (
    tester,
  ) async {
    await pump(tester, const HomeLoaded(userName: 'Amrut', weight: 70));

    expect(find.textContaining('Amrut'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byType(WaterIntakeCard), findsOneWidget);
  });

  for (final code in ['hi', 'mr']) {
    testWidgets('loaded fits the screen in $code (no overflow)', (
      tester,
    ) async {
      await pump(
        tester,
        const HomeLoaded(userName: 'Amrut', weight: 70),
        locale: Locale(code),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Amrut'), findsOneWidget);
      expect(find.byType(WaterIntakeCard), findsOneWidget);
    });
  }

  testWidgets('loaded meets accessibility guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, const HomeLoaded(userName: 'Amrut', weight: 70));
    await expectAccessible(tester, semantics);
  });

  testWidgets('loaded at the largest text size: no overflow', (tester) async {
    useLargestText(tester);
    await pump(tester, const HomeLoaded(userName: 'Amrut', weight: 70));
    expectNoOverflow(tester);
  });
}
