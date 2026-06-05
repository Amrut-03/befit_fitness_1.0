import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile_entity.dart';

import '../../domain/usecases/get_profile.dart';

import '../../domain/usecases/update_profile.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;

  final UpdateProfile updateProfile;

  ProfileBloc(this.getProfile, this.updateProfile) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);

    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,

    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final profile = await getProfile();

      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      print(
        "UPDATING PROFILE: "
        "${event.profile.weight}",
      );

      await updateProfile(event.profile);

      final updatedProfile = await getProfile();

      print(
        "RELOADED PROFILE: "
        "${updatedProfile.weight}",
      );

      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      print(e);

      emit(ProfileError(e.toString()));
    }
  }
}
