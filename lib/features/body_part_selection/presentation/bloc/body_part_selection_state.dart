import 'package:equatable/equatable.dart';
import 'package:flutter_body_part_selector/feature/flutter_body_part_selector/domain/entities/muscle.dart';

class BodySelectionState extends Equatable {
  final Set<Muscle> selectedMuscles;
  final Set<Muscle> disabledMuscles;
  final bool isFront;

  const BodySelectionState({
    required this.selectedMuscles,
    required this.disabledMuscles,
    required this.isFront,
  });

  factory BodySelectionState.initial() {
    return const BodySelectionState(
      selectedMuscles: {},
      disabledMuscles: {},
      isFront: true,
    );
  }

  BodySelectionState copyWith({
    Set<Muscle>? selectedMuscles,
    Set<Muscle>? disabledMuscles,
    bool? isFront,
  }) {
    return BodySelectionState(
      selectedMuscles: selectedMuscles ?? this.selectedMuscles,
      disabledMuscles: disabledMuscles ?? this.disabledMuscles,
      isFront: isFront ?? this.isFront,
    );
  }

  @override
  List<Object> get props => [selectedMuscles, disabledMuscles, isFront];
}
