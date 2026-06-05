import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeDashboard>(_onLoadHomeDashboard);
    on<RefreshHomeDashboard>(_onRefreshHomeDashboard);
  }

  Future<void> _onLoadHomeDashboard(
    LoadHomeDashboard event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      emit(const HomeLoaded(userName: 'Amrut', weight: 72.5));
    } catch (e) {
      emit(const HomeError(message: 'Failed to load dashboard'));
    }
  }

  Future<void> _onRefreshHomeDashboard(
    RefreshHomeDashboard event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      emit(const HomeLoaded(userName: 'Amrut', weight: 72.0));
    } catch (e) {
      emit(const HomeError(message: 'Failed to refresh data'));
    }
  }
}
