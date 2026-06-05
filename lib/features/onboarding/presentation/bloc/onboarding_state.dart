import 'package:equatable/equatable.dart';

class OnboardingProfileState extends Equatable {
  final String? selectedGoal;
  final String? selectedGender;
  final double weight;
  final double height;
  final double age;
  final String? activityLevel;
  final bool isLoading;
  final bool profileSaved;
  final bool saveSuccess;
  final String? error;

  const OnboardingProfileState({
    this.selectedGoal,
    this.selectedGender,
    this.weight = 70,
    this.height = 170,
    this.age = 22,
    this.activityLevel,
    this.isLoading = false,
    this.saveSuccess = false,
    this.profileSaved = false,
    this.error,
  });

  OnboardingProfileState copyWith({
    String? selectedGoal,
    String? selectedGender,
    double? weight,
    double? height,
    bool? saveSuccess,
    double? age,
    String? activityLevel,
    bool? isLoading,
    bool? profileSaved,
    String? error,
  }) {
    return OnboardingProfileState(
      selectedGoal: selectedGoal ?? this.selectedGoal,
      selectedGender: selectedGender ?? this.selectedGender,
      weight: weight ?? this.weight,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      height: height ?? this.height,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      isLoading: isLoading ?? this.isLoading,
      profileSaved: profileSaved ?? this.profileSaved,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    selectedGoal,
    selectedGender,
    weight,
    height,
    age,
    activityLevel,
    isLoading,
    profileSaved,
    error,
  ];
}
