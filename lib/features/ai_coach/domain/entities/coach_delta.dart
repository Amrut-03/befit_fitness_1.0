import 'package:equatable/equatable.dart';

import 'coach_message.dart';

/// A piece of a streamed coach answer and where it came from.
class CoachDelta extends Equatable {
  const CoachDelta(this.text, this.source);

  final String text;
  final CoachSource source;

  @override
  List<Object?> get props => [text, source];
}
