import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:fitness_app/features/profile/domain/usecases/get_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetProfile getProfile;
  final GetCurrentUser getCurrentUser;

  HomeLoaded? _lastLoaded;

  HomeBloc({required this.getProfile, required this.getCurrentUser})
    : super(HomeInitial()) {
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

    final name = profile.name.isNotEmpty
        ? profile.name
        : ((await getCurrentUser())?.name ?? '');

    _lastLoaded = HomeLoaded(userName: name, weight: profile.weight);

    emit(_lastLoaded!);
  }
}
