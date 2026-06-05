import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String email;
  final String goal;
  final String gender;
  final double weight;
  final double height;
  final double age;
  final String activityLevel;
  final bool profileCompleted;
  final int dailyStepGoal;
  final int dailyCalorieGoal;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;

  const UserProfileEntity({
    required this.goal,
    required this.gender,
    required this.weight,
    required this.height,
    required this.age,
    required this.activityLevel,
    required this.profileCompleted,
    required this.dailyStepGoal,
    required this.dailyCalorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.email,
  });

  @override
  List<Object?> get props => [
    email,
    goal,
    gender,
    weight,
    height,
    age,
    activityLevel,
    profileCompleted,
    dailyStepGoal,
    dailyCalorieGoal,
    proteinGoal,
    carbsGoal,
    fatGoal,
  ];
}
