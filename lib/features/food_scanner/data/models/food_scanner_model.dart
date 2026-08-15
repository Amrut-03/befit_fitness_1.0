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
    final product = json['product'] ?? {};

    double parseNutrient(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is num) return value.toDouble();
      final p = double.tryParse(value.toString());
      return p ?? 0;
    }

    return FoodItemModel(
      barcode: json['code'] ?? '',

      name: product['product_name'] ?? 'Unknown Product',

      brand: product['brands'],

      imageUrl: product['image_front_url'],

      calories: parseNutrient(product['nutriments']?['energy-kcal_100g']),

      protein: parseNutrient(product['nutriments']?['proteins_100g']),

      carbs: parseNutrient(product['nutriments']?['carbohydrates_100g']),

      fat: parseNutrient(product['nutriments']?['fat_100g']),
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