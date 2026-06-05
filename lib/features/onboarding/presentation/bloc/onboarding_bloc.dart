import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/is_profile_completed.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/save_user_profile.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingProfileBloc
    extends Bloc<OnboardingProfileEvent, OnboardingProfileState> {
  final SaveUserProfile saveUserProfile;

  final GetUserProfile getUserProfile;

  final IsProfileCompleted isProfileCompleted;

  OnboardingProfileBloc({
    required this.saveUserProfile,
    required this.getUserProfile,
    required this.isProfileCompleted,
  }) : super(const OnboardingProfileState()) {
    on<SelectGoalEvent>((event, emit) {
      emit(state.copyWith(selectedGoal: event.goal));
    });

    on<SelectGenderEvent>((event, emit) {
      emit(state.copyWith(selectedGender: event.gender));
    });

    on<UpdateWeightEvent>((event, emit) {
      emit(state.copyWith(weight: event.weight));
    });

    on<UpdateHeightEvent>((event, emit) {
      emit(state.copyWith(height: event.height));
    });

    on<UpdateAgeEvent>((event, emit) {
      emit(state.copyWith(age: event.age));
    });

    on<SelectActivityLevelEvent>((event, emit) {
      emit(
        state.copyWith(activityLevel: event.activityLevel, saveSuccess: false),
      );
    });

    on<SaveProfileEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));

      final user = FirebaseAuth.instance.currentUser;

      try {
        final profile = UserProfileEntity(
          email: user?.email ?? '',
          goal: event.goal,
          gender: event.gender,
          weight: event.weight,
          height: event.height,
          age: event.age,
          activityLevel: event.activityLevel,
          profileCompleted: true,
          dailyStepGoal: event.dailyStepGoal,
          dailyCalorieGoal: event.dailyCalorieGoal,
          proteinGoal: event.proteinGoal,
          carbsGoal: event.carbsGoal,
          fatGoal: event.fatGoal,
        );

        await saveUserProfile(profile);

        emit(state.copyWith(isLoading: false, saveSuccess: true));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    on<LoadProfileEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));

      try {
        final profile = await getUserProfile();

        if (profile != null) {
          emit(
            state.copyWith(
              isLoading: false,
              selectedGoal: profile.goal,
              selectedGender: profile.gender,
              weight: profile.weight,
              height: profile.height,
              age: profile.age,
              activityLevel: profile.activityLevel,
            ),
          );
        } else {
          emit(state.copyWith(isLoading: false, error: "Profile not found"));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    on<CheckProfileCompletedEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        final completed = await isProfileCompleted();

        emit(state.copyWith(isLoading: false, profileSaved: completed));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}
