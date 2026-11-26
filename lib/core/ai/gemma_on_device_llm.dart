import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_mediapipe/flutter_edge_ai_mediapipe.dart';

import 'device_memory.dart';
import 'on_device_llm.dart';

/// [OnDeviceLlm] backed by `flutter_edge_ai` (formerly `flutter_gemma`) with
/// the MediaPipe engine, running a Gemma `.task` model downloaded from
/// [modelUrl].
///
/// MediaPipe rather than LiteRT-LM because LiteRT-LM needs Android minSdk 30
/// and BeFit supports Android 10 (API 29).
///
/// The plugin initialises lazily on first use, so app start-up pays nothing
/// until the user opens the coach or Home asks for insights.
class GemmaOnDeviceLlm implements OnDeviceLlm {
  GemmaOnDeviceLlm({
    required this.modelUrl,
    this.minRamMb = 3500,
    this.maxTokens = 2048,
    DeviceMemory memory = deviceRamMb,
    bool Function()? isMobile,
  }) : _memory = memory,
       _isMobile = isMobile ?? (() => Platform.isAndroid || Platform.isIOS);

  /// Where the model is downloaded from. Empty means "not configured".
  final String modelUrl;

  /// Devices with less RAM fall back to the cloud model. Gemma 3 1B (int4)
  /// needs roughly 1–1.5 GB while generating.
  final int minRamMb;

  /// Prompt + response token budget (must not exceed the model's KV cache).
  final int maxTokens;

  final DeviceMemory _memory;
  final bool Function() _isMobile;

  bool _initialized = false;
  bool? _supported;
  InferenceModel? _model;
  CancelToken? _cancelToken;

  /// Completes when the in-flight generation finishes: the engine runs one
  /// session at a time, so Home insights and the coach must not overlap.
  Future<void> _lock = Future.value();

  /// File name of the model, which flutter_edge_ai uses as its id. Derived
  /// exactly as the plugin does: the URL's last (decoded) path segment.
  String get modelId {
    final segments = Uri.tryParse(modelUrl)?.pathSegments ?? const [];
    return segments.isEmpty ? '' : segments.last;
  }

  /// The plugin stores the model under [modelId], so it must be a plain
  /// `.task` file name. A Firebase Storage URL of a file inside a folder
  /// encodes the folder into that segment (`models%2Fgemma.task`) and can't
  /// be installed: upload the file at the bucket root.
  bool get _validUrl {
    final id = modelId;
    final ok =
        modelUrl.startsWith('https://') &&
        id.endsWith('.task') &&
        !id.contains('/') &&
        !id.contains(r'\');
    if (!ok && modelUrl.isNotEmpty) {
      debugPrint(
        'GemmaOnDeviceLlm: GEMMA_MODEL_URL must be an https URL whose last '
        'path segment is a plain .task file name (got "$id"). On-device AI '
        'is disabled.',
      );
    }
    return ok;
  }

  Future<void> _init() async {
    if (_initialized) return;
    await FlutterEdgeAi.initialize(inferenceEngines: [const MediaPipeEngine()]);
    _initialized = true;
  }

  Future<bool> _isSupported() async {
    final cached = _supported;
    if (cached != null) return cached;
    if (!_isMobile()) return _supported = false;
    final ram = await _memory();
    // Unknown RAM: let the user try; generation failures fall back to cloud.
    return _supported = ram == null || ram >= minRamMb;
  }

  @override
  Future<OnDeviceModelStatus> status() async {
    if (!_validUrl) return OnDeviceModelStatus.notConfigured;
    if (!await _isSupported()) return OnDeviceModelStatus.unsupported;
    try {
      await _init();
      final installed = await FlutterEdgeAi.isModelInstalled(modelId);
      return installed && FlutterEdgeAi.hasActiveModel()
          ? OnDeviceModelStatus.ready
          : OnDeviceModelStatus.notDownloaded;
    } catch (e, s) {
      _log('status', e, s);
      return OnDeviceModelStatus.notDownloaded;
    }
  }

  @override
  Future<void> download({void Function(int percent)? onProgress}) async {
    if (!_validUrl) {
      throw const OnDeviceLlmUnavailable('No valid model URL configured');
    }
    await _init();
    final token = _cancelToken = CancelToken();
    try {
      final builder = FlutterEdgeAi.installModel(
        modelType: ModelType.gemmaIt,
        fileType: ModelFileType.task,
      ).fromNetwork(modelUrl).withCancelToken(token);
      if (onProgress != null) builder.withProgress(onProgress);
      await builder.install();
    } finally {
      if (identical(_cancelToken, token)) _cancelToken = null;
    }
  }

  @override
  void cancel() => _cancelToken?.cancel('Cancelled by user');

  @override
  Future<void> delete() async {
    await _init();
    final model = _model;
    _model = null;
    await model?.close();
    await FlutterEdgeAi.uninstallModel(modelId);
  }

  @override
  Future<Stream<String>> generate(
    String prompt, {
    String? systemInstruction,
    double temperature = 0.7,
  }) async {
    final previous = _lock;
    final done = Completer<void>();
    _lock = done.future;
    void release() {
      if (!done.isCompleted) done.complete();
    }

    await previous;
    try {
      final chat = await _createChat(systemInstruction, temperature);
      await chat.addQueryChunk(Message.text(text: prompt, isUser: true));
      final tokens = chat.generateChatResponseAsync();

      StreamSubscription<ModelResponse>? sub;
      var finished = false;
      Future<void> finish({required bool stop}) async {
        if (finished) return;
        finished = true;
        if (stop) {
          try {
            await chat.stopGeneration();
          } catch (_) {}
        }
        await sub?.cancel();
        try {
          await chat.close();
        } catch (_) {}
        release();
      }

      late final StreamController<String> controller;
      controller = StreamController<String>(
        onListen: () {
          sub = tokens.listen(
            (r) {
              if (r is TextResponse && r.token.isNotEmpty) {
                controller.add(r.token);
              }
            },
            onError: controller.addError,
            onDone: () async {
              await finish(stop: false);
              await controller.close();
            },
          );
        },
        // Also called after onDone; `finish` runs once.
        onCancel: () => finish(stop: true),
      );
      return controller.stream;
    } on OnDeviceLlmUnavailable {
      release();
      rethrow;
    } catch (e, s) {
      release();
      _log('generate', e, s);
      throw OnDeviceLlmUnavailable('$e');
    }
  }

  Future<InferenceChat> _createChat(
    String? systemInstruction,
    double temperature,
  ) async {
    if (await status() != OnDeviceModelStatus.ready) {
      throw const OnDeviceLlmUnavailable('Model not installed');
    }
    final model = _model ??= await _loadModel();
    return model.openChat(
      temperature: temperature,
      topK: 40,
      topP: 0.95,
      modelType: ModelType.gemmaIt,
      systemInstruction: systemInstruction,
    );
  }

  /// GPU is much faster on Android, but some GPUs can't load the model: retry
  /// on CPU. iOS always uses CPU: loading a `.task` model on the GPU exceeds
  /// the app's memory limit and iOS kills the app.
  Future<InferenceModel> _loadModel() async {
    if (Platform.isIOS) {
      return FlutterEdgeAi.getActiveModel(
        maxTokens: maxTokens,
        preferredBackend: PreferredBackend.cpu,
      );
    }
    try {
      return await FlutterEdgeAi.getActiveModel(
        maxTokens: maxTokens,
        preferredBackend: PreferredBackend.gpu,
      );
    } catch (e, s) {
      _log('GPU load', e, s);
      return FlutterEdgeAi.getActiveModel(
        maxTokens: maxTokens,
        preferredBackend: PreferredBackend.cpu,
      );
    }
  }

  static void _log(String op, Object e, StackTrace s) =>
      debugPrint('GemmaOnDeviceLlm.$op failed: $e\n$s');
}
