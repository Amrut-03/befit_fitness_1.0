import 'package:equatable/equatable.dart';

import '../../domain/entities/health_metrics_entity.dart';

abstract class HealthMetricEvent extends Equatable {
  const HealthMetricEvent();

  @override
  List<Object?> get props => [];
}

class LoadHealthMetrics extends HealthMetricEvent {
  final MetricType type;

  const LoadHealthMetrics(this.type);

  @override
  List<Object?> get props => [type];
}

class SaveHealthMetricEvent extends HealthMetricEvent {
  final HealthMetricEntity metric;

  const SaveHealthMetricEvent(this.metric);

  @override
  List<Object?> get props => [metric];
}

class DeleteHealthMetricEvent extends HealthMetricEvent {
  final DateTime date;

  final MetricType type;

  const DeleteHealthMetricEvent({required this.date, required this.type});

  @override
  List<Object?> get props => [date, type];
}
