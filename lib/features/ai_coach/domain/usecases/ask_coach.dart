import '../entities/coach_context.dart';
import '../entities/coach_delta.dart';
import '../entities/coach_message.dart';
import '../repositories/coach_repository.dart';
import '../services/coach_prompt_builder.dart';
import '../services/coach_safety.dart';

class AskCoach {
  const AskCoach(this._repository, [this._prompts = const CoachPromptBuilder()])
    : _language = _english,
      _cannedText = null;

  /// [language] is the language the coach replies in (e.g. "Hindi");
  /// [cannedText] returns the safety replies in that language.
  const AskCoach.localized(
    this._repository, {
    required String Function() language,
    required String Function(CannedReply) cannedText,
    CoachPromptBuilder prompts = const CoachPromptBuilder(),
  }) : _prompts = prompts,
       _language = language,
       _cannedText = cannedText;

  final CoachRepository _repository;
  final CoachPromptBuilder _prompts;
  final String Function() _language;
  final String Function(CannedReply)? _cannedText;

  static String _english() => 'English';

  Stream<CoachDelta> call({
    required String question,
    required CoachContext context,
    List<CoachMessage> history = const [],
  }) {
    final kind = CoachSafety.classify(question);
    if (kind != null) {
      final text =
          _cannedText?.call(kind) ?? CoachSafety.cannedReply(question)!;
      return Stream.value(CoachDelta(text, CoachSource.rule));
    }
    return _repository.reply(
      _prompts.build(
        question: question,
        context: context,
        history: history,
        language: _language(),
      ),
    );
  }
}
