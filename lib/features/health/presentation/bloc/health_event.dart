import 'package:equatable/equatable.dart';

abstract class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object?> get props => [];
}

class LoadHealthData extends HealthEvent {}

class RefreshHealthData extends HealthEvent {}

/// The user tapped "Connect" on the Health Connect / Apple Health prompt.
class ConnectHealthPlatformRequested extends HealthEvent {}
