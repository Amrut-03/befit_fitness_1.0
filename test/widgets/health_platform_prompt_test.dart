import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/health/health_platform_service.dart';
import 'package:fitness_app/features/health/domain/entities/health_data_entity.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_event.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_state.dart';
import 'package:fitness_app/features/health/presentation/widgets/health_platform_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'pump_app.dart';

class _Health extends MockBloc<HealthEvent, HealthState>
    implements HealthBloc {}

class _FakeEvent extends Fake implements HealthEvent {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeEvent()));

  late _Health bloc;

  setUp(() => bloc = _Health());

  Future<void> pump(
    WidgetTester tester,
    HealthPlatformStatus status, {
    bool isIOS = false,
  }) async {
    when(() => bloc.state).thenReturn(
      HealthLoaded(
        data: const HealthDataEntity(steps: 0, calories: 0, moveMinutes: 0),
        platformStatus: status,
      ),
    );
    await tester.pumpApp(
      Scaffold(
        body: BlocProvider<HealthBloc>.value(
          value: bloc,
          child: HealthPlatformPrompt(isIOS: isIOS),
        ),
      ),
    );
  }

  testWidgets('Android, not connected: Connect Health Connect', (t) async {
    await pump(t, HealthPlatformStatus.notConnected);

    expect(find.text('Connect Health Connect'), findsOneWidget);
    await t.tap(find.text('Connect'));
    verify(
      () => bloc.add(any(that: isA<ConnectHealthPlatformRequested>())),
    ).called(1);
  });

  testWidgets('iOS, not connected: Connect Apple Health', (t) async {
    await pump(t, HealthPlatformStatus.notConnected, isIOS: true);

    expect(find.text('Connect Apple Health'), findsOneWidget);
  });

  testWidgets('Health Connect missing: Install', (t) async {
    await pump(t, HealthPlatformStatus.needsInstall);

    expect(find.text('Install'), findsOneWidget);
  });

  for (final status in [
    HealthPlatformStatus.connected,
    HealthPlatformStatus.unsupported,
  ]) {
    testWidgets('hidden when ${status.name}', (t) async {
      await pump(t, status);

      expect(find.byType(TextButton), findsNothing);
    });
  }
}
