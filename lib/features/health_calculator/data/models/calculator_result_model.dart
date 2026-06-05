import '../../domain/entities/calculator_result_entity.dart';

class CalculatorResultModel extends CalculatorResultEntity {
  const CalculatorResultModel({
    required super.value,

    required super.title,

    required super.description,
  });

  factory CalculatorResultModel.fromJson(Map<String, dynamic> json) {
    return CalculatorResultModel(
      value: (json['value'] as num).toDouble(),

      title: json['title'],

      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'title': title, 'description': description};
  }
}
