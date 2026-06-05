import 'package:equatable/equatable.dart';

class FoodItemEntity extends Equatable {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;

  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const FoodItemEntity({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  List<Object?> get props => [
    barcode,
    name,
    brand,
    imageUrl,
    calories,
    protein,
    carbs,
    fat,
  ];
}
