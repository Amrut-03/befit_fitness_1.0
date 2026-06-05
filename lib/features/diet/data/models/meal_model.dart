import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/meal_entity.dart';

class MealModel extends MealEntity {
  const MealModel({
    required super.id,
    required super.name,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    super.alarmTime,
    super.consumedAt,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    print("MEAL ${json['name']} CONSUMED = ${json['consumedAt']}");
    return MealModel(
      id: json['id'],
      name: json['name'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      alarmTime: json['alarmTime'] != null
          ? json['alarmTime'] is Timestamp
                ? (json['alarmTime'] as Timestamp).toDate()
                : DateTime.parse(json['alarmTime'])
          : null,
      consumedAt: json['consumedAt'] != null
          ? json['consumedAt'] is Timestamp
                ? (json['consumedAt'] as Timestamp).toDate()
                : DateTime.parse(json['consumedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'alarmTime': alarmTime?.toIso8601String(),
      'consumedAt': consumedAt?.toIso8601String(),
    };
  }

  factory MealModel.fromEntity(MealEntity entity) {
    return MealModel(
      id: entity.id,
      name: entity.name,
      calories: entity.calories,
      protein: entity.protein,
      carbs: entity.carbs,
      fat: entity.fat,
      alarmTime: entity.alarmTime,
      consumedAt: entity.consumedAt,
    );
  }

  MealEntity toEntity() {
    return MealEntity(
      id: id,
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      alarmTime: alarmTime,
      consumedAt: consumedAt,
    );
  }
}
