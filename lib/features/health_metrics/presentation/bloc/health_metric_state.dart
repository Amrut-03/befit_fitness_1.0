import 'package:equatable/equatable.dart';

import '../../domain/entities/health_metrics_entity.dart';

abstract class HealthMetricState extends Equatable {
  const HealthMetricState();

  @override
  List<Object?> get props => [];
}

class HealthMetricInitial extends HealthMetricState {}

class HealthMetricLoading extends HealthMetricState {}

class HealthMetricLoaded extends HealthMetricState {
  final List<HealthMetricEntity> metrics;

  const HealthMetricLoaded({required this.metrics});

  @override
  List<Object?> get props => [metrics];
}

class HealthMetricError extends HealthMetricState {
  final String message;

  const HealthMetricError(this.message);

  @override
  List<Object?> get props => [message];
}
