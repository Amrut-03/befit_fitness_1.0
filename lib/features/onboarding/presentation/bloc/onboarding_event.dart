import 'package:equatable/equatable.dart';

abstract class OnboardingProfileEvent extends Equatable {
  const OnboardingProfileEvent();

  @override
  List<Object?> get props => [];
}

class SelectGoalEvent extends OnboardingProfileEvent {
  final String goal;

  const SelectGoalEvent(this.goal);

  @override
  List<Object?> get props => [goal];
}

class SelectGenderEvent extends OnboardingProfileEvent {
  final String gender;

  const SelectGenderEvent(this.gender);

  @override
  List<Object?> get props => [gender];
}

class UpdateWeightEvent extends OnboardingProfileEvent {
  final double weight;

  const UpdateWeightEvent(this.weight);

  @override
  List<Object?> get props => [weight];
}

class UpdateHeightEvent extends OnboardingProfileEvent {
  final double height;

  const UpdateHeightEvent(this.height);

  @override
  List<Object?> get props => [height];
}

class UpdateAgeEvent extends OnboardingProfileEvent {
  final double age;

  const UpdateAgeEvent(this.age);

  @override
  List<Object?> get props => [age];
}

class SelectActivityLevelEvent extends OnboardingProfileEvent {
  final String activityLevel;

  const SelectActivityLevelEvent(this.activityLevel);

  @override
  List<Object?> get props => [activityLevel];
}

class SaveProfileEvent extends OnboardingProfileEvent {
  final String goal;
  final String gender;
  final double weight;
  final double height;
  final double age;
  final String activityLevel;
  final int dailyStepGoal;
  final int dailyCalorieGoal;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;

  const SaveProfileEvent({
    required this.goal,
    required this.gender,
    required this.weight,
    required this.height,
    required this.age,
    required this.activityLevel,
    required this.dailyStepGoal,
    required this.dailyCalorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  @override
  List<Object?> get props => [
    goal,
    gender,
    weight,
    height,
    age,
    activityLevel,
    dailyStepGoal,
    dailyCalorieGoal,
    proteinGoal,
    carbsGoal,
    fatGoal,
  ];
}

class LoadProfileEvent extends OnboardingProfileEvent {}

class CheckProfileCompletedEvent extends OnboardingProfileEvent {}
