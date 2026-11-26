import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/health/health_platform_service.dart';
import 'package:fitness_app/features/health/domain/entities/health_data_entity.dart';
import 'package:fitness_app/features/health/domain/usecases/connect_health_platform.dart';
import 'package:fitness_app/features/health/domain/usecases/get_health_data.dart';
import 'package:fitness_app/features/health/domain/usecases/get_health_platform_status.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_event.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetHealthData extends Mock implements GetHealthData {}

class _MockGetStatus extends Mock implements GetHealthPlatformStatus {}

class _MockConnect extends Mock implements ConnectHealthPlatform {}

void main() {
  late _MockGetHealthData getData;
  late _MockGetStatus getStatus;
  late _MockConnect connect;

  const pedometerData = HealthDataEntity(
    steps: 1000,
    calories: 40,
    moveMinutes: 10,
  );
  const platformData = HealthDataEntity(
    steps: 9000,
    calories: 350,
    moveMinutes: 75,
    source: ActivitySource.healthPlatform,
  );

  HealthBloc build() => HealthBloc(
    getHealthData: getData,
    getPlatformStatus: getStatus,
    connectPlatform: connect,
  );

  setUp(() {
    getData = _MockGetHealthData();
    getStatus = _MockGetStatus();
    connect = _MockConnect();
  });

  blocTest<HealthBloc, HealthState>(
    'load emits loading, then data with the platform status',
    setUp: () {
      when(
        () => getStatus(),
      ).thenAnswer((_) async => HealthPlatformStatus.notConnected);
      when(() => getData()).thenAnswer((_) async => pedometerData);
    },
    build: build,
    act: (bloc) => bloc.add(LoadHealthData()),
    expect: () => [
      HealthLoading(),
      const HealthLoaded(
        data: pedometerData,
        platformStatus: HealthPlatformStatus.notConnected,
      ),
    ],
  );

  blocTest<HealthBloc, HealthState>(
    'connecting reloads with platform data',
    setUp: () {
      var connected = false;
      when(() => connect()).thenAnswer((_) async {
        connected = true;
        return HealthPlatformStatus.connected;
      });
      when(() => getStatus()).thenAnswer(
        (_) async => connected
            ? HealthPlatformStatus.connected
            : HealthPlatformStatus.notConnected,
      );
      when(
        () => getData(),
      ).thenAnswer((_) async => connected ? platformData : pedometerData);
    },
    build: build,
    act: (bloc) => bloc.add(ConnectHealthPlatformRequested()),
    expect: () => [
      const HealthLoaded(
        data: platformData,
        platformStatus: HealthPlatformStatus.connected,
      ),
    ],
    verify: (_) => verify(() => connect()).called(1),
  );

  blocTest<HealthBloc, HealthState>(
    'a failed connect still reloads, keeping the prompt',
    setUp: () {
      when(() => connect()).thenThrow(Exception('denied'));
      when(
        () => getStatus(),
      ).thenAnswer((_) async => HealthPlatformStatus.notConnected);
      when(() => getData()).thenAnswer((_) async => pedometerData);
    },
    build: build,
    act: (bloc) => bloc.add(ConnectHealthPlatformRequested()),
    expect: () => [
      const HealthLoaded(
        data: pedometerData,
        platformStatus: HealthPlatformStatus.notConnected,
      ),
    ],
  );

  blocTest<HealthBloc, HealthState>(
    'a data error emits HealthError',
    setUp: () {
      when(
        () => getStatus(),
      ).thenAnswer((_) async => HealthPlatformStatus.connected);
      when(() => getData()).thenThrow(Exception('boom'));
    },
    build: build,
    act: (bloc) => bloc.add(RefreshHealthData()),
    expect: () => [isA<HealthError>()],
  );
}
