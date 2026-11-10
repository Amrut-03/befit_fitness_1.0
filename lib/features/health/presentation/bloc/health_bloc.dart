import 'package:fitness_app/core/error/failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/connect_health_platform.dart';
import '../../domain/usecases/get_health_data.dart';
import '../../domain/usecases/get_health_platform_status.dart';
import 'health_event.dart';
import 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final GetHealthData getHealthData;
  final GetHealthPlatformStatus getPlatformStatus;
  final ConnectHealthPlatform connectPlatform;

  HealthBloc({
    required this.getHealthData,
    required this.getPlatformStatus,
    required this.connectPlatform,
  }) : super(HealthInitial()) {
    on<LoadHealthData>((event, emit) async {
      emit(HealthLoading());
      await _load(emit);
    });

    on<RefreshHealthData>((event, emit) => _load(emit));

    on<ConnectHealthPlatformRequested>((event, emit) async {
      try {
        await connectPlatform();
      } catch (_) {
        // Status is re-read below; a failed request just leaves the prompt.
      }
      await _load(emit);
    });
  }

  Future<void> _load(Emitter<HealthState> emit) async {
    try {
      final status = await getPlatformStatus();
      final data = await getHealthData();
      emit(HealthLoaded(data: data, platformStatus: status));
    } catch (e) {
      emit(HealthError(message: Failure.fromException(e).message));
    }
  }
}
