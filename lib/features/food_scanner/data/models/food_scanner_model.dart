import 'package:fitness_app/core/utils/json_read.dart';
import 'package:fitness_app/features/food_scanner/domain/entities/scanned_food_entity.dart';

class FoodItemModel extends FoodItemEntity {
  const FoodItemModel({
    required super.barcode,
    required super.name,
    super.brand,
    super.imageUrl,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    final product = asMap(json['product']);

    double parseNutrient(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is num) return value.toDouble();
      final p = double.tryParse(value.toString());
      return p ?? 0;
    }

    String? nonEmpty(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    final nutriments = asMap(product['nutriments']);

    // Some products only list energy in kJ.
    var calories = parseNutrient(nutriments['energy-kcal_100g']);
    if (calories == 0) {
      calories = parseNutrient(nutriments['energy_100g']) / 4.184;
    }

    return FoodItemModel(
      barcode: json['code'] ?? '',

      name:
          nonEmpty(product['product_name']) ??
          nonEmpty(product['product_name_en']) ??
          nonEmpty(product['generic_name']) ??
          'Unknown Product',

      brand: product['brands'],

      imageUrl: product['image_front_url'],

      calories: double.parse(calories.toStringAsFixed(1)),

      protein: parseNutrient(nutriments['proteins_100g']),

      carbs: parseNutrient(nutriments['carbohydrates_100g']),

      fat: parseNutrient(nutriments['fat_100g']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  FoodItemModel copyWith({
    String? barcode,
    String? name,
    String? brand,
    String? imageUrl,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return FoodItemModel(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }
}
