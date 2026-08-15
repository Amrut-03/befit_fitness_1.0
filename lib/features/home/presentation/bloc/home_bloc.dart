import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_app/features/profile/domain/usecases/get_profile.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetProfile getProfile;

  HomeLoaded? _lastLoaded;

  HomeBloc({required this.getProfile}) : super(HomeInitial()) {
    on<LoadHomeDashboard>(_onLoadHomeDashboard);
    on<RefreshHomeDashboard>(_onRefreshHomeDashboard);
  }

  Future<void> _onLoadHomeDashboard(
    LoadHomeDashboard event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      await _emitLoaded(emit);
    } catch (e) {
      if (_lastLoaded != null) {
        emit(_lastLoaded!);
      } else {
        emit(const HomeError(message: 'Failed to load dashboard'));
      }
    }
  }

  Future<void> _onRefreshHomeDashboard(
    RefreshHomeDashboard event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _emitLoaded(emit);
    } catch (e) {
      if (_lastLoaded != null) {
        emit(_lastLoaded!);
      }
    }
  }

  Future<void> _emitLoaded(Emitter<HomeState> emit) async {
    final profile = await getProfile();

    final authUser = FirebaseAuth.instance.currentUser;

    final name = profile.name.isNotEmpty
        ? profile.name
        : (authUser?.displayName ?? '');

    _lastLoaded = HomeLoaded(userName: name, weight: profile.weight);

    emit(_lastLoaded!);
  }
}
