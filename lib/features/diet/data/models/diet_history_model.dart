import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/diet_history_entity.dart';

class DietHistoryModel {
  final String id;

  final String planId;

  final String planName;

  final double calories;

  final double protein;

  final double carbs;

  final double fat;

  final DateTime completedAt;

  final List<String> meals;

  const DietHistoryModel({
    required this.id,

    required this.planId,

    required this.planName,

    required this.calories,

    required this.protein,

    required this.carbs,

    required this.fat,

    required this.completedAt,

    required this.meals,
  });

  factory DietHistoryModel.fromJson(Map<String, dynamic> json) {
    return DietHistoryModel(
      id: json['id'] ?? '',

      planId: json['planId'] ?? '',

      planName: json['planName'] ?? '',

      calories: (json['calories'] ?? 0).toDouble(),

      protein: (json['protein'] ?? 0).toDouble(),

      carbs: (json['carbs'] ?? 0).toDouble(),

      fat: (json['fat'] ?? 0).toDouble(),

      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : DateTime.now(),

      meals: List<String>.from(json['meals'] ?? []),
    );
  }

  factory DietHistoryModel.fromEntity(DietHistoryEntity entity) {
    return DietHistoryModel(
      id: entity.id,

      planId: entity.planId,

      planName: entity.planName,

      calories: entity.calories,

      protein: entity.protein,

      carbs: entity.carbs,

      fat: entity.fat,

      completedAt: entity.completedAt,

      meals: entity.meals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'planId': planId,

      'planName': planName,

      'calories': calories,

      'protein': protein,

      'carbs': carbs,

      'fat': fat,

      'completedAt': Timestamp.fromDate(completedAt),
      'meals': meals,
    };
  }

  DietHistoryEntity toEntity() {
    return DietHistoryEntity(
      id: id,

      planId: planId,

      planName: planName,

      calories: calories,

      protein: protein,

      carbs: carbs,

      fat: fat,

      completedAt: completedAt,

      meals: meals,
    );
  }
}
