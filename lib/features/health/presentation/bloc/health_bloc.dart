import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_health_data.dart';

import 'health_event.dart';

import 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final GetHealthData getHealthData;

  HealthBloc({required this.getHealthData}) : super(HealthInitial()) {
    on<LoadHealthData>(_onLoadHealthData);

    on<RefreshHealthData>(_onRefreshHealthData);
  }

  Future<void> _onLoadHealthData(
    LoadHealthData event,

    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());

    try {
      final result = await getHealthData();

      emit(HealthLoaded(data: result));
    } catch (e) {
      emit(HealthError(message: e.toString()));
    }
  }

  Future<void> _onRefreshHealthData(
    RefreshHealthData event,

    Emitter<HealthState> emit,
  ) async {
    try {
      final result = await getHealthData();

      emit(HealthLoaded(data: result));
    } catch (e) {
      emit(HealthError(message: e.toString()));
    }
  }
}
