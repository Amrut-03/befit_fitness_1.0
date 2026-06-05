import 'package:equatable/equatable.dart';

class FoodItemEntity extends Equatable {
  final String id;
  final String name;

  final String? brand;
  final String? imageUrl;

  final String? source;
  final String? barcode;

  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  final double? quantity;
  final String? unit;

  final DateTime? createdAt;

  const FoodItemEntity({
    required this.id,
    required this.name,
    this.brand,
    this.imageUrl,
    required this.source,
    this.quantity = 100,
    this.unit = 'g',
    this.barcode,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    brand,
    imageUrl,
    source,
    barcode,
    calories,
    protein,
    carbs,
    fat,
    unit,
    quantity,
    createdAt,
  ];
}
