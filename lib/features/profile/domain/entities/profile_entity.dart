import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String name;

  final String email;

  final String? photoUrl;

  final String goal;

  final int streak;

  final double weight;

  final double height;

  final double age;

  final String gender;

  final int dailyStepGoal;

  final int dailyCalorieGoal;

  final String activityLevel;

  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;

  const ProfileEntity({
    required this.name,

    required this.email,

    required this.goal,

    required this.streak,

    required this.weight,

    required this.height,

    required this.age,

    required this.gender,

    this.photoUrl,

    required this.dailyStepGoal,

    required this.dailyCalorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.activityLevel,
  });

  @override
  List<Object?> get props => [
    name,

    email,

    photoUrl,

    goal,

    streak,

    weight,

    height,

    age,

    gender,

    dailyStepGoal,

    dailyCalorieGoal,

    proteinGoal,
    carbsGoal,
    fatGoal,
    activityLevel,
  ];
}
