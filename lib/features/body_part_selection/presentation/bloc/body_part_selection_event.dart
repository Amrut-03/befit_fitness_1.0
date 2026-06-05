import 'package:equatable/equatable.dart';
import 'package:flutter_body_part_selector/feature/flutter_body_part_selector/domain/entities/muscle.dart';

abstract class BodySelectionEvent extends Equatable {
  const BodySelectionEvent();

  @override
  List<Object?> get props => [];
}

class ToggleMuscle extends BodySelectionEvent {
  final Muscle muscle;

  const ToggleMuscle(this.muscle);

  @override
  List<Object?> get props => [muscle];
}

class ToggleView extends BodySelectionEvent {
  const ToggleView();
}

class ToggleDisableMuscle extends BodySelectionEvent {
  final Muscle muscle;

  const ToggleDisableMuscle(this.muscle);

  @override
  List<Object?> get props => [muscle];
}
