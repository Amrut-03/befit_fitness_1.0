import 'package:equatable/equatable.dart';

class AIInsightEntity extends Equatable {
  final String title;

  final String message;

  final String emoji;

  const AIInsightEntity({
    required this.title,

    required this.message,

    required this.emoji,
  });

  @override
  List<Object?> get props => [title, message, emoji];
}
