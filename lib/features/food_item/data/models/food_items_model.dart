import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/features/food_item/domain/entities/food_items_entity.dart';

class FoodItemModel extends FoodItemEntity {
  const FoodItemModel({
    required super.id,
    required super.name,
    super.brand,
    super.imageUrl,
    required super.source,
    super.barcode,
    super.calories,
    super.protein,
    super.carbs,
    super.fat,
    super.quantity,
    super.unit,
    super.createdAt,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      imageUrl: json['imageUrl'],
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 100,
      unit: json['unit'] ?? 'g',
      source: json['source'],
      barcode: json['barcode'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'quantity': quantity,
      'unit': unit,
      'source': source,
      'barcode': barcode,
      'createdAt': createdAt,
    };
  }

  factory FoodItemModel.fromEntity(FoodItemEntity entity) {
    return FoodItemModel(
      id: entity.id,
      name: entity.name,
      brand: entity.brand,
      imageUrl: entity.imageUrl,
      source: entity.source,
      barcode: entity.barcode,
      calories: entity.calories,
      protein: entity.protein,
      carbs: entity.carbs,
      fat: entity.fat,
      quantity: entity.quantity,
      unit: entity.unit,
      createdAt: entity.createdAt,
    );
  }

  FoodItemEntity toEntity() {
    return FoodItemEntity(
      id: id,
      name: name,
      brand: brand,
      imageUrl: imageUrl,
      source: source,
      barcode: barcode,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      quantity: quantity,
      unit: unit,
      createdAt: createdAt,
    );
  }
}
