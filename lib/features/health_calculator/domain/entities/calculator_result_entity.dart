import 'package:equatable/equatable.dart';

class CalculatorResultEntity extends Equatable {
  final double value;

  final String title;

  final String description;

  const CalculatorResultEntity({
    required this.value,

    required this.title,

    required this.description,
  });

  @override
  List<Object?> get props => [value, title, description];
}
