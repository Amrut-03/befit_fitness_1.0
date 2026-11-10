import 'package:fitness_app/core/error/failures.dart';
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
      emit(ProfileError(Failure.fromException(e).message));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await updateProfile(event.profile);

      final updatedProfile = await getProfile();

      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError(Failure.fromException(e).message));
    }
  }
}
