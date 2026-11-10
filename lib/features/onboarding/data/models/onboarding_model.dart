import 'package:fitness_app/core/utils/json_read.dart';
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
      weight: asDouble(json['weight']),
      height: asDouble(json['height']),
      age: asDouble(json['age']),
      activityLevel: json['activityLevel'] ?? '',
      profileCompleted: json['profileCompleted'] ?? false,
      dailyStepGoal: asInt(json['dailyStepGoal']),
      dailyCalorieGoal: asInt(json['dailyCalorieGoal']),
      proteinGoal: asInt(json['proteinGoal']),
      carbsGoal: asInt(json['carbsGoal']),
      fatGoal: asInt(json['fatGoal']),
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
