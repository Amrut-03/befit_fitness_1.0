import 'package:equatable/equatable.dart';

enum CoachRole { user, coach }

/// Where an answer was generated.
enum CoachSource { onDevice, cloud, rule }

class CoachMessage extends Equatable {
  const CoachMessage({
    required this.role,
    required this.text,
    this.source,
    this.failed = false,
  });

  const CoachMessage.user(this.text)
    : role = CoachRole.user,
      source = null,
      failed = false;

  final CoachRole role;
  final String text;

  /// Set on coach messages.
  final CoachSource? source;

  /// The answer couldn't be generated; [text] explains why.
  final bool failed;

  bool get isUser => role == CoachRole.user;

  CoachMessage copyWith({String? text, CoachSource? source, bool? failed}) =>
      CoachMessage(
        role: role,
        text: text ?? this.text,
        source: source ?? this.source,
        failed: failed ?? this.failed,
      );

  @override
  List<Object?> get props => [role, text, source, failed];
}
