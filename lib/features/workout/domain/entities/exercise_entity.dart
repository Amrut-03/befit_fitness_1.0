import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String id;
  final String name;
  final String bodyPart;
  final String target;
  final String equipment;
  final String? gifUrl;
  final List<String> instructions;

  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.target,
    required this.equipment,
    this.gifUrl,
    required this.instructions,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    bodyPart,
    target,
    equipment,
    gifUrl,
    instructions,
  ];
}
