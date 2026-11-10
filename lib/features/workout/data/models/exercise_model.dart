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

  /// Parses an exercise from the open-source ExerciseDB v1 API
  /// (`exerciseId`, `bodyParts[]`, `targetMuscles[]`, `equipments[]`).
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: (json['exerciseId'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      bodyPart: _first(json['bodyParts']),
      target: _first(json['targetMuscles']),
      equipment: _first(json['equipments']),
      gifUrl: json['gifUrl'] as String?,
      instructions: (json['instructions'] as List<dynamic>? ?? const [])
          .map((step) => step.toString().replaceFirst(_stepPrefix, '').trim())
          .where((step) => step.isNotEmpty)
          .toList(),
    );
  }

  /// Matches the "Step:1 " prefix the API puts on each instruction; the UI
  /// renders its own step numbers.
  static final RegExp _stepPrefix = RegExp(r'^Step\s*:?\s*\d+\s*[:.-]?\s*');

  static String _first(dynamic value) {
    if (value is List && value.isNotEmpty) return value.first.toString();
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': id,
      'name': name,
      'bodyParts': [bodyPart],
      'targetMuscles': [target],
      'equipments': [equipment],
      'gifUrl': gifUrl,
      'instructions': instructions,
    };
  }
}
