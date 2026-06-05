import 'package:fitness_app/features/diet/domain/entities/macro_entity.dart';

class MacroModel {
  final double carbs;
  final double protein;
  final double fat;

  MacroModel({required this.carbs, required this.protein, required this.fat});

  factory MacroModel.fromJson(Map<String, dynamic> json) {
    return MacroModel(
      carbs: (json["carbs"] as num).toDouble(),
      protein: (json["protein"] as num).toDouble(),
      fat: (json["fat"] as num).toDouble(),
    );
  }
}

extension MacroMapper on MacroModel {
  MacroEntity toEntity() {
    return MacroEntity(carbs: carbs, protein: protein, fat: fat);
  }
}
