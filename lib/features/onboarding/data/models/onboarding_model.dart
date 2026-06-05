import 'package:fitness_app/features/onboarding/domain/entities/onboarding_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.goal,
    required super.gender,
    required super.weight,
    required super.height,
    required super.age,
    required super.activityLevel,
    required super.profileCompleted,
    required super.dailyStepGoal,
    required super.dailyCalorieGoal,
    required super.proteinGoal,
    required super.carbsGoal,
    required super.fatGoal,
    required super.email,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      goal: json['goal'] ?? '',
      gender: json['gender'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      age: (json['age'] ?? 0).toDouble(),
      activityLevel: json['activityLevel'] ?? '',
      profileCompleted: json['profileCompleted'] ?? false,
      dailyStepGoal: json['dailyStepGoal'] ?? 0,
      dailyCalorieGoal: json['dailyCalorieGoal'] ?? 0,
      proteinGoal: json['proteinGoal'] ?? 0,
      carbsGoal: json['carbsGoal'] ?? 0,
      fatGoal: json['fatGoal'] ?? 0,
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'gender': gender,
      'weight': weight,
      'height': height,
      'age': age,
      'activityLevel': activityLevel,
      'profileCompleted': profileCompleted,
      'dailyStepGoal': dailyStepGoal,
      'email': email,
      'dailyCalorieGoal': dailyCalorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
    };
  }
}
