import 'package:fitness_app/features/ai_insights/domain/entites/ai_insights_entity.dart';

class AIInsightModel extends AIInsightEntity {
  const AIInsightModel({
    required super.title,

    required super.message,

    required super.emoji,
  });

  factory AIInsightModel.fromJson(Map<String, dynamic> json) {
    return AIInsightModel(
      title: json['title'] ?? '',

      message: json['message'] ?? '',

      emoji: json['emoji'] ?? '🤖',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'message': message, 'emoji': emoji};
  }
}
