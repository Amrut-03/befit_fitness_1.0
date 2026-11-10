import 'package:fitness_app/features/body_part_selection/presentation/bloc/body_part_selection_bloc.dart';
import 'package:get_it/get_it.dart';

/// Dependencies for the body part selection feature.
void registerBodyPartSelectionDependencies(GetIt sl) {
  sl.registerFactory(() => BodySelectionBloc());
}
