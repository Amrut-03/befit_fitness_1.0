import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';

class ExerciseModel extends ExerciseEntity {
  const ExerciseModel({
    required super.id,
    required super.name,
    required super.bodyPart,
    required super.target,
    required super.equipment,
    super.gifUrl,
    required super.instructions,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'].toString(),

      name: json['name'] ?? '',

      bodyPart: json['bodyPart'] ?? '',

      target: json['target'] ?? '',

      equipment: json['equipment'] ?? '',

      gifUrl: json['gifUrl'],

      instructions: json['instructions'] != null
          ? List<String>.from(json['instructions'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'target': target,
      'equipment': equipment,
      'gifUrl': gifUrl,
      'instructions': instructions,
    };
  }
}
