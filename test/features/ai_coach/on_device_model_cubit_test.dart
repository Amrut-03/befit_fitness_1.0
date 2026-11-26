import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/ai/on_device_llm.dart';
import 'package:fitness_app/features/ai_coach/presentation/cubit/on_device_model_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_on_device_llm.dart';

void main() {
  late FakeOnDeviceLlm llm;

  setUp(() => llm = FakeOnDeviceLlm());

  const notDownloaded = OnDeviceModelState(
    status: OnDeviceModelStatus.notDownloaded,
  );

  blocTest<OnDeviceModelCubit, OnDeviceModelState>(
    'check reports the status',
    build: () => OnDeviceModelCubit(llm),
    act: (c) => c.check(),
    expect: () => [notDownloaded],
  );

  blocTest<OnDeviceModelCubit, OnDeviceModelState>(
    'download reports progress and ends ready',
    build: () => OnDeviceModelCubit(llm),
    seed: () => notDownloaded,
    act: (c) => c.download(),
    expect: () => const [
      OnDeviceModelState(
        status: OnDeviceModelStatus.notDownloaded,
        downloading: true,
      ),
      OnDeviceModelState(
        status: OnDeviceModelStatus.notDownloaded,
        downloading: true,
        progress: 10,
      ),
      OnDeviceModelState(
        status: OnDeviceModelStatus.notDownloaded,
        downloading: true,
        progress: 60,
      ),
      OnDeviceModelState(
        status: OnDeviceModelStatus.notDownloaded,
        downloading: true,
        progress: 100,
      ),
      OnDeviceModelState(status: OnDeviceModelStatus.ready, progress: 100),
    ],
  );

  blocTest<OnDeviceModelCubit, OnDeviceModelState>(
    'a failed download shows an error',
    setUp: () => llm
      ..progress = const []
      ..downloadError = Exception('404'),
    build: () => OnDeviceModelCubit(llm),
    seed: () => notDownloaded,
    act: (c) => c.download(),
    skip: 1,
    expect: () => [
      notDownloaded.copyWith(
        error: 'Download failed. Check your connection and try again.',
      ),
    ],
  );

  test('cancel ends the download without an error', () async {
    llm
      ..progress = const [5]
      ..downloadGate = Completer<void>();
    final cubit = OnDeviceModelCubit(llm);
    await cubit.check();
    final download = cubit.download();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.downloading, isTrue);

    cubit.cancel();
    await download;

    expect(cubit.state, notDownloaded);
    await cubit.close();
  });

  blocTest<OnDeviceModelCubit, OnDeviceModelState>(
    'download is ignored when the device is unsupported',
    build: () => OnDeviceModelCubit(llm),
    seed: () =>
        const OnDeviceModelState(status: OnDeviceModelStatus.unsupported),
    act: (c) => c.download(),
    expect: () => const <OnDeviceModelState>[],
  );

  blocTest<OnDeviceModelCubit, OnDeviceModelState>(
    'delete removes the model and rechecks',
    setUp: () => llm.current = OnDeviceModelStatus.ready,
    build: () => OnDeviceModelCubit(llm),
    seed: () => const OnDeviceModelState(status: OnDeviceModelStatus.ready),
    act: (c) => c.delete(),
    expect: () => [notDownloaded],
    verify: (_) => expect(llm.deleted, isTrue),
  );
}
