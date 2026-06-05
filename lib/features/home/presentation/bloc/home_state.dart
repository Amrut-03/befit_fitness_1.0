part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String userName;
  final double weight;

  const HomeLoaded({required this.userName, required this.weight});

  @override
  List<Object?> get props => [userName, weight];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
