part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final ProfileEntity profile;

  UpdateProfileEvent(this.profile);
}
