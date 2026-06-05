import 'package:fitness_app/features/body_part_selection/presentation/bloc/body_part_selection_event.dart';
import 'package:fitness_app/features/body_part_selection/presentation/bloc/body_part_selection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_body_part_selector/feature/flutter_body_part_selector/domain/entities/muscle.dart';

class BodySelectionBloc extends Bloc<BodySelectionEvent, BodySelectionState> {
  BodySelectionBloc() : super(BodySelectionState.initial()) {
    on<ToggleMuscle>(_onToggleMuscle);
    on<ToggleView>(_onToggleView);
    on<ToggleDisableMuscle>(_onToggleDisableMuscle);
  }

  void _onToggleMuscle(ToggleMuscle event, Emitter<BodySelectionState> emit) {
    final updated = Set<Muscle>.from(state.selectedMuscles);

    if (updated.contains(event.muscle)) {
      updated.remove(event.muscle);
    } else {
      updated.add(event.muscle);
    }

    emit(state.copyWith(selectedMuscles: updated));
  }

  void _onToggleView(ToggleView event, Emitter<BodySelectionState> emit) {
    emit(state.copyWith(isFront: !state.isFront));
  }

  void _onToggleDisableMuscle(
    ToggleDisableMuscle event,
    Emitter<BodySelectionState> emit,
  ) {
    final disabled = Set<Muscle>.from(state.disabledMuscles);

    if (disabled.contains(event.muscle)) {
      disabled.remove(event.muscle);
    } else {
      disabled.add(event.muscle);
    }

    emit(state.copyWith(disabledMuscles: disabled));
  }
}
