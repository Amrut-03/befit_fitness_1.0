import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/features/diet/data/models/diet_plan_model.dart';
import 'package:fitness_app/features/diet/data/models/meal_model.dart';
import 'package:fitness_app/features/food_item/data/models/food_items_model.dart';
import 'package:fitness_app/features/health_metrics/data/models/health_metric_model.dart';
import 'package:fitness_app/features/health_metrics/domain/entities/health_metrics_entity.dart';
import 'package:fitness_app/features/onboarding/data/models/onboarding_model.dart';
import 'package:fitness_app/features/profile/data/models/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Local time: Timestamp.toDate() returns local DateTimes.
  final consumed = DateTime(2026, 11, 10, 8, 30);

  MealModel meal() => MealModel(
    id: 'm1',
    name: 'Oats',
    calories: 350,
    protein: 12,
    carbs: 60,
    fat: 6,
    quantity: 80,
    unit: 'g',
    consumedAt: consumed,
  );

  group('MealModel', () {
    test('round-trips through JSON', () {
      final parsed = MealModel.fromJson(meal().toJson());
      expect(parsed.toJson(), meal().toJson());
    });

    test('reads Firestore Timestamps and fills defaults', () {
      final parsed = MealModel.fromJson({
        'id': 7,
        'name': 'Egg',
        'calories': 70,
        'consumedAt': Timestamp.fromDate(consumed),
      });
      expect(parsed.id, '7');
      expect(parsed.calories, 70.0);
      expect(parsed.protein, 0);
      expect(parsed.quantity, 100);
      expect(parsed.unit, 'g');
      expect(parsed.consumedAt, consumed);
    });
  });

  group('DietPlanModel', () {
    test('round-trips with meals and activeDate', () {
      final plan = DietPlanModel(
        id: 'p1',
        name: 'Cut',
        meals: [meal()],
        activeDate: consumed,
      );
      final parsed = DietPlanModel.fromJson(plan.toJson());

      expect(parsed.toJson(), plan.toJson());
    });

    test('handles missing meals and activeDate', () {
      final parsed = DietPlanModel.fromJson({'id': 'p2'});
      expect(parsed.meals, isEmpty);
      expect(parsed.activeDate, isNull);
      expect(parsed.name, '');
    });
  });

  group('FoodItemModel', () {
    test('round-trips and parses createdAt from any supported type', () {
      final item = FoodItemModel(
        id: 'f1',
        name: 'Greek yogurt',
        brand: 'Acme',
        source: 'barcode',
        barcode: '123',
        calories: 59,
        protein: 10,
        createdAt: consumed,
      );
      final parsed = FoodItemModel.fromJson(item.toJson());
      expect(parsed.toEntity(), item.toEntity());

      final fromTimestamp = FoodItemModel.fromJson({
        ...item.toJson(),
        'createdAt': Timestamp.fromDate(consumed),
      });
      final fromString = FoodItemModel.fromJson({
        ...item.toJson(),
        'createdAt': consumed.toIso8601String(),
      });
      expect(fromTimestamp.createdAt, consumed);
      expect(fromString.createdAt, consumed);
    });
  });

  group('HealthMetricModel', () {
    test('round-trips through JSON', () {
      final metric = HealthMetricModel(
        id: 'h1',
        type: MetricType.weight,
        date: consumed,
        value: 71.5,
        isManual: true,
      );
      final parsed = HealthMetricModel.fromJson(metric.toJson());
      expect(parsed, metric);
    });
  });

  group('ProfileModel', () {
    final json = {
      'name': 'Amrut',
      'email': 'a@example.com',
      'goal': 'Muscle Gain',
      'streak': 4,
      'weight': 70,
      'height': 175.5,
      'age': 25,
      'gender': 'Male',
      'dailyStepGoal': 8000,
      'dailyCalorieGoal': 2600,
      'proteinGoal': 150,
      'carbsGoal': 300,
      'fatGoal': 70,
      'activityLevel': 'Active',
    };

    test('round-trips through JSON', () {
      final parsed = ProfileModel.fromJson(json);
      expect(ProfileModel.fromJson(parsed.toJson()), parsed);
      expect(parsed.weight, 70.0);
    });

    test('tolerates doubles in int fields and missing fields', () {
      final parsed = ProfileModel.fromJson({
        ...json,
        'dailyCalorieGoal': 2600.0,
        'streak': null,
      });
      expect(parsed.dailyCalorieGoal, 2600);
      expect(parsed.streak, 0);

      final empty = ProfileModel.fromJson({});
      expect(empty.goal, 'Fitness Goal');
      expect(empty.activityLevel, 'Sedentary');
    });
  });

  group('UserProfileModel', () {
    test('tolerates doubles in goal fields', () {
      final parsed = UserProfileModel.fromJson({
        'proteinGoal': 150.0,
        'dailyStepGoal': 8000,
        'profileCompleted': true,
      });
      expect(parsed.proteinGoal, 150);
      expect(parsed.dailyStepGoal, 8000);
      expect(parsed.profileCompleted, isTrue);
    });
  });
}
