/// Lifecycle of the on-device model (Gemma via MediaPipe).
enum OnDeviceModelStatus {
  /// No model URL was provided at build time (`--dart-define=GEMMA_MODEL_URL`).
  notConfigured,

  /// The device can't run the model (not Android/iOS, or too little RAM).
  unsupported,

  /// Supported, but the model file isn't on the device yet.
  notDownloaded,

  /// Installed and ready to generate.
  ready,
}

/// Thrown when the model can't generate (not installed, or the engine failed
/// to load). Callers fall back to the cloud model.
class OnDeviceLlmUnavailable implements Exception {
  const OnDeviceLlmUnavailable(this.reason);

  final String reason;

  @override
  String toString() => 'OnDeviceLlmUnavailable: $reason';
}

/// Text generation on the device, with no network and no API key.
///
/// The model belongs to the device, not the BeFit account, so it survives
/// logout. Generation is serialised: one response at a time.
abstract interface class OnDeviceLlm {
  Future<OnDeviceModelStatus> status();

  /// Downloads and installs the model, reporting 0–100. Completes when the
  /// model is ready. Throws on failure or when [cancel] is called.
  Future<void> download({void Function(int percent)? onProgress});

  /// Cancels an in-flight [download].
  void cancel();

  /// Removes the model file to free storage.
  Future<void> delete();

  /// Streams the response to [prompt] token by token. Cancelling the
  /// subscription stops generation.
  ///
  /// Throws [OnDeviceLlmUnavailable] when the model isn't ready.
  Future<Stream<String>> generate(
    String prompt, {
    String? systemInstruction,
    double temperature,
  });
}
