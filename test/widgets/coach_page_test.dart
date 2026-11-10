import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/ai/on_device_llm.dart';
import 'package:fitness_app/features/ai_coach/domain/entities/coach_message.dart';
import 'package:fitness_app/features/ai_coach/presentation/bloc/coach_bloc.dart';
import 'package:fitness_app/features/ai_coach/presentation/cubit/on_device_model_cubit.dart';
import 'package:fitness_app/features/ai_coach/presentation/pages/coach_page.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_event.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_state.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/progress_report/presentation/bloc/weekly_report_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_event.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_state.dart';
import 'package:fitness_app/features/water_intake/presentation/bloc/water_intake_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'pump_app.dart';

class _Coach extends MockBloc<CoachEvent, CoachState> implements CoachBloc {}

class _Model extends MockCubit<OnDeviceModelState>
    implements OnDeviceModelCubit {}

class _Profile extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class _Health extends MockBloc<HealthEvent, HealthState>
    implements HealthBloc {}

class _Streak extends MockBloc<StreakEvent, StreakState>
    implements StreakBloc {}

class _Water extends MockBloc<WaterIntakeEvent, WaterIntakeState>
    implements WaterIntakeBloc {}

class _Report extends MockBloc<WeeklyReportEvent, WeeklyReportState>
    implements WeeklyReportBloc {}

void main() {
  late _Coach coach;
  late _Model model;
  late _Report report;
  late _Water water;

  setUpAll(() {
    registerFallbackValue(const CoachStopRequested());
    registerFallbackValue(const WeeklyReportRefreshed());
    registerFallbackValue(const WaterIntakeStarted());
  });

  Future<void> pump(
    WidgetTester t, {
    CoachState chat = const CoachState(),
    OnDeviceModelState modelState = const OnDeviceModelState(
      status: OnDeviceModelStatus.notDownloaded,
    ),
  }) async {
    coach = _Coach();
    model = _Model();
    report = _Report();
    water = _Water();
    final profile = _Profile();
    final health = _Health();
    final streak = _Streak();
    when(() => coach.state).thenReturn(chat);
    when(() => model.state).thenReturn(modelState);
    when(() => model.check()).thenAnswer((_) async {});
    when(() => model.download()).thenAnswer((_) async {});
    when(() => report.state).thenReturn(const WeeklyReportState());
    when(() => water.state).thenReturn(const WaterIntakeState());
    when(() => profile.state).thenReturn(ProfileInitial());
    when(() => health.state).thenReturn(HealthInitial());
    when(() => streak.state).thenReturn(const StreakState(currentStreak: 2));

    await t.pumpApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<CoachBloc>.value(value: coach),
          BlocProvider<OnDeviceModelCubit>.value(value: model),
          BlocProvider<ProfileBloc>.value(value: profile),
          BlocProvider<HealthBloc>.value(value: health),
          BlocProvider<StreakBloc>.value(value: streak),
          BlocProvider<WaterIntakeBloc>.value(value: water),
          BlocProvider<WeeklyReportBloc>.value(value: report),
        ],
        child: const CoachPage(),
      ),
    );
  }

  testWidgets('empty chat shows suggestions; tapping one asks it', (t) async {
    await pump(t);

    verify(() => model.check()).called(1);
    verify(() => report.add(const WeeklyReportRequested())).called(1);
    verify(() => water.add(const WaterIntakeStarted())).called(1);

    await t.tap(find.text(CoachPage.suggestions.first));
    final event =
        verify(() => coach.add(captureAny())).captured.single
            as CoachQuestionSubmitted;
    expect(event.question, CoachPage.suggestions.first);
    expect(event.context.streakDays, 2);
  });

  testWidgets('typing and sending asks the coach', (t) async {
    await pump(t);

    await t.enterText(find.byType(TextField), 'Leg day ideas?');
    await t.tap(find.byTooltip('Send'));

    final event =
        verify(() => coach.add(captureAny())).captured.single
            as CoachQuestionSubmitted;
    expect(event.question, 'Leg day ideas?');
  });

  testWidgets('offers the model download', (t) async {
    await pump(t);

    expect(find.text('Run the coach offline'), findsOneWidget);
    await t.tap(find.text('Download'));
    verify(() => model.download()).called(1);
  });

  testWidgets('shows download progress with cancel', (t) async {
    await pump(
      t,
      modelState: const OnDeviceModelState(
        status: OnDeviceModelStatus.notDownloaded,
        downloading: true,
        progress: 42,
      ),
    );

    expect(find.text('Downloading Gemma… 42%'), findsOneWidget);
    await t.tap(find.text('Cancel'));
    verify(() => model.cancel()).called(1);
  });

  testWidgets('ready model hides the card', (t) async {
    await pump(
      t,
      modelState: const OnDeviceModelState(status: OnDeviceModelStatus.ready),
    );
    expect(find.text('Run the coach offline'), findsNothing);
  });

  testWidgets('messages, source labels and stop while generating', (t) async {
    await pump(
      t,
      chat: const CoachState(
        generating: true,
        messages: [
          CoachMessage.user('How am I doing?'),
          CoachMessage(
            role: CoachRole.coach,
            text: 'Great week so far.',
            source: CoachSource.onDevice,
          ),
          CoachMessage.user('And protein?'),
          CoachMessage(role: CoachRole.coach, text: ''),
        ],
      ),
    );

    expect(find.text('How am I doing?'), findsOneWidget);
    expect(find.text('Great week so far.'), findsOneWidget);
    expect(find.text('On-device'), findsOneWidget);
    expect(find.text('Thinking…'), findsOneWidget);
    expect(find.text(CoachPage.suggestions.first), findsNothing);

    await t.tap(find.byTooltip('Stop'));
    verify(() => coach.add(const CoachStopRequested())).called(1);
  });
}
