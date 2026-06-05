import 'package:equatable/equatable.dart';

import '../../domain/entities/health_data_entity.dart';

abstract class HealthState extends Equatable {
  const HealthState();

  @override
  List<Object?> get props => [];
}

class HealthInitial extends HealthState {}

class HealthLoading extends HealthState {}

class HealthLoaded extends HealthState {
  final HealthDataEntity data;

  const HealthLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class HealthError extends HealthState {
  final String message;

  const HealthError({required this.message});

  @override
  List<Object?> get props => [message];
}
