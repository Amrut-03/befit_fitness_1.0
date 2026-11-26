import 'dart:async';

import 'package:fitness_app/core/ai/on_device_llm.dart';

/// Scriptable [OnDeviceLlm] for tests.
class FakeOnDeviceLlm implements OnDeviceLlm {
  FakeOnDeviceLlm({this.current = OnDeviceModelStatus.notDownloaded});

  OnDeviceModelStatus current;

  /// Tokens [generate] streams, or an error to throw from [generate].
  List<String> tokens = const [];
  Object? generateError;

  /// Thrown from the token stream after the tokens.
  Object? streamError;

  /// Download behaviour.
  List<int> progress = const [10, 60, 100];
  Object? downloadError;
  Completer<void>? downloadGate;
  bool cancelled = false;
  bool deleted = false;

  final prompts = <String>[];
  final systemInstructions = <String?>[];

  @override
  Future<OnDeviceModelStatus> status() async => current;

  @override
  Future<void> download({void Function(int percent)? onProgress}) async {
    for (final p in progress) {
      onProgress?.call(p);
    }
    await downloadGate?.future;
    if (cancelled) throw Exception('Download cancelled');
    if (downloadError != null) throw downloadError!;
    current = OnDeviceModelStatus.ready;
  }

  @override
  void cancel() {
    cancelled = true;
    if (downloadGate?.isCompleted == false) downloadGate!.complete();
  }

  @override
  Future<void> delete() async {
    deleted = true;
    current = OnDeviceModelStatus.notDownloaded;
  }

  @override
  Future<Stream<String>> generate(
    String prompt, {
    String? systemInstruction,
    double temperature = 0.7,
  }) async {
    prompts.add(prompt);
    systemInstructions.add(systemInstruction);
    if (generateError != null) throw generateError!;
    final err = streamError;
    return Stream.fromIterable(tokens)
        .asyncExpand((t) => Stream.value(t))
        .transform(
          StreamTransformer<String, String>.fromHandlers(
            handleDone: (sink) {
              if (err != null) sink.addError(err);
              sink.close();
            },
          ),
        );
  }
}
