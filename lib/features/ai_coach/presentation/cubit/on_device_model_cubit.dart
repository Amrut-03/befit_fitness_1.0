import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/ai/on_device_llm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnDeviceModelState extends Equatable {
  const OnDeviceModelState({
    this.status,
    this.downloading = false,
    this.progress = 0,
    this.error,
  });

  /// Null while the first check is running.
  final OnDeviceModelStatus? status;
  final bool downloading;

  /// 0–100 while [downloading].
  final int progress;
  final String? error;

  bool get isReady => status == OnDeviceModelStatus.ready;

  /// Whether the "download the model" offer applies to this device.
  bool get canDownload => status == OnDeviceModelStatus.notDownloaded;

  OnDeviceModelState copyWith({
    OnDeviceModelStatus? status,
    bool? downloading,
    int? progress,
    String? error,
    bool clearError = false,
  }) => OnDeviceModelState(
    status: status ?? this.status,
    downloading: downloading ?? this.downloading,
    progress: progress ?? this.progress,
    error: clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [status, downloading, progress, error];
}

/// Downloads, checks and removes the on-device model. Lives above the user
/// scope: the model belongs to the device, and a download keeps going when
/// the user navigates away.
class OnDeviceModelCubit extends Cubit<OnDeviceModelState> {
  OnDeviceModelCubit(this._llm) : super(const OnDeviceModelState());

  final OnDeviceLlm _llm;

  Future<void> check() async {
    if (state.downloading) return;
    final status = await _llm.status();
    if (!isClosed) emit(state.copyWith(status: status));
  }

  Future<void> download() async {
    if (state.downloading || !state.canDownload) return;
    emit(state.copyWith(downloading: true, progress: 0, clearError: true));
    try {
      await _llm.download(
        onProgress: (p) {
          if (!isClosed && p != state.progress) {
            emit(state.copyWith(progress: p.clamp(0, 100)));
          }
        },
      );
      final status = await _llm.status();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: status,
          downloading: false,
          error: status == OnDeviceModelStatus.ready
              ? null
              : 'The model downloaded but couldn\'t be set up.',
        ),
      );
    } catch (e) {
      debugPrint('On-device model download failed: $e');
      if (isClosed) return;
      final cancelled = e.toString().toLowerCase().contains('cancel');
      emit(
        state.copyWith(
          downloading: false,
          progress: 0,
          error: cancelled
              ? null
              : 'Download failed. Check your connection and try again.',
          clearError: cancelled,
        ),
      );
    }
  }

  void cancel() => _llm.cancel();

  Future<void> delete() async {
    if (state.downloading) return;
    try {
      await _llm.delete();
    } catch (e) {
      debugPrint('Deleting on-device model failed: $e');
    }
    await check();
  }
}
