import '../entities/coach_context.dart';
import '../entities/coach_delta.dart';
import '../entities/coach_message.dart';
import '../repositories/coach_repository.dart';
import '../services/coach_prompt_builder.dart';
import '../services/coach_safety.dart';

class AskCoach {
  const AskCoach(
    this._repository, [
    this._prompts = const CoachPromptBuilder(),
  ]);

  final CoachRepository _repository;
  final CoachPromptBuilder _prompts;

  Stream<CoachDelta> call({
    required String question,
    required CoachContext context,
    List<CoachMessage> history = const [],
  }) {
    final canned = CoachSafety.cannedReply(question);
    if (canned != null) {
      return Stream.value(CoachDelta(canned, CoachSource.rule));
    }
    return _repository.reply(
      _prompts.build(question: question, context: context, history: history),
    );
  }
}
