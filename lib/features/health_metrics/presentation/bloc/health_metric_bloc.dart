import 'package:fitness_app/features/health_metrics/domain/usecases/delete_health_metrics.dart';
import 'package:fitness_app/features/health_metrics/domain/usecases/save_health_metrics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_health_metrics.dart';

import 'health_metric_event.dart';

import 'health_metric_state.dart';

class HealthMetricsBloc extends Bloc<HealthMetricEvent, HealthMetricState> {
  final GetHealthMetrics getHealthMetrics;

  final SaveHealthMetric saveHealthMetric;

  final DeleteHealthMetric deleteHealthMetric;

  HealthMetricsBloc(
    this.getHealthMetrics,

    this.saveHealthMetric,

    this.deleteHealthMetric,
  ) : super(HealthMetricInitial()) {
    on<LoadHealthMetrics>(_onLoadMetrics);

    on<SaveHealthMetricEvent>(_onSaveMetric);

    on<DeleteHealthMetricEvent>(_onDeleteMetric);
  }

  Future<void> _onLoadMetrics(
    LoadHealthMetrics event,

    Emitter<HealthMetricState> emit,
  ) async {
    emit(HealthMetricLoading());

    try {
      final result = await getHealthMetrics(event.type);

      emit(HealthMetricLoaded(metrics: result));
    } catch (e) {
      emit(HealthMetricError(e.toString()));
    }
  }

  Future<void> _onSaveMetric(
    SaveHealthMetricEvent event,

    Emitter<HealthMetricState> emit,
  ) async {
    try {
      await saveHealthMetric(event.metric);

      add(LoadHealthMetrics(event.metric.type));
    } catch (e) {
      emit(HealthMetricError(e.toString()));
    }
  }

  Future<void> _onDeleteMetric(
    DeleteHealthMetricEvent event,

    Emitter<HealthMetricState> emit,
  ) async {
    try {
      await deleteHealthMetric(event.date);

      add(LoadHealthMetrics(event.type));
    } catch (e) {
      emit(HealthMetricError(e.toString()));
    }
  }
}
