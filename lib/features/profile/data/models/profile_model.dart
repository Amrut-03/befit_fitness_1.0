import 'package:fitness_app/core/utils/json_read.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.name,

    required super.email,

    required super.goal,

    required super.streak,

    required super.weight,

    required super.height,

    required super.age,

    required super.gender,

    required super.dailyStepGoal,

    required super.dailyCalorieGoal,

    super.photoUrl,
    required super.proteinGoal,
    required super.carbsGoal,
    required super.fatGoal,
    required super.activityLevel,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',

      email: json['email'] ?? '',

      goal: json['goal'] ?? 'Fitness Goal',

      streak: json['streak'] ?? 0,

      weight: asDouble(json['weight']),

      height: asDouble(json['height']),

      age: asDouble(json['age']),

      gender: json['gender'] ?? 'Male',

      photoUrl: json['photoUrl'],

      dailyStepGoal: json['dailyStepGoal'] ?? 0,

      dailyCalorieGoal: json['dailyCalorieGoal'] ?? 0,
      proteinGoal: json['proteinGoal'] ?? 0,
      carbsGoal: json['carbsGoal'] ?? 0,
      fatGoal: json['fatGoal'] ?? 0,
      activityLevel: json['activityLevel'] ?? 'Sedentary',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,

      'email': email,

      'goal': goal,

      'streak': streak,

      'weight': weight,

      'height': height,

      'age': age,

      'gender': gender,

      'photoUrl': photoUrl,

      'dailyStepGoal': dailyStepGoal,

      'dailyCalorieGoal': dailyCalorieGoal,

      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'activityLevel': activityLevel,
    };
  }
}
