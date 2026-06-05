import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fitness_app/features/diet/domain/entities/diet_plan_entity.dart';

import 'meal_model.dart';

class DietPlanModel {
  final String id;

  final String name;

  final List<MealModel> meals;

  final DateTime? activeDate;

  DietPlanModel({
    required this.id,

    required this.name,

    required this.meals,

    this.activeDate,
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> json) {
    final parsedActiveDate = json['activeDate'] != null
        ? (json['activeDate'] as Timestamp).toDate()
        : null;

    final model = DietPlanModel(
      id: json['id'].toString(),

      name: json['name'] ?? '',

      activeDate: parsedActiveDate,

      meals: (json['meals'] as List<dynamic>? ?? [])
          .map((e) => MealModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );

    print("MODEL CREATED ${model.name} ACTIVE=${model.activeDate}");

    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'name': name,

      'activeDate': activeDate == null ? null : Timestamp.fromDate(activeDate!),

      'meals': meals.map((e) => MealModel.fromEntity(e).toJson()).toList(),
    };
  }

  DietPlanEntity toEntity() {
    print("MODEL FIELD BEFORE ENTITY = $activeDate");

    final entity = DietPlanEntity(
      id: id,

      name: name,

      activeDate: activeDate,

      meals: meals.map((e) => e.toEntity()).toList(),
    );

    print("ENTITY FIELD AFTER ENTITY = ${entity.activeDate}");

    return entity;
  }

  factory DietPlanModel.fromEntity(DietPlanEntity entity) {
    return DietPlanModel(
      id: entity.id,

      name: entity.name,

      activeDate: entity.activeDate,

      meals: entity.meals.map((e) => MealModel.fromEntity(e)).toList(),
    );
  }
}
