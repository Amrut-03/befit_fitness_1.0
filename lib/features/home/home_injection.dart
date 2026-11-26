import 'package:fitness_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:get_it/get_it.dart';

/// Dependencies for the home feature.
void registerHomeDependencies(GetIt sl) {
  sl.registerFactory(() => HomeBloc(getProfile: sl(), getCurrentUser: sl()));
}
