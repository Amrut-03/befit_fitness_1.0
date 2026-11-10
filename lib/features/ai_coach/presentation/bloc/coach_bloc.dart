import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/ai_insights/presentation/bloc/ai_insights_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/coach_context.dart';
import '../../domain/entities/coach_delta.dart';
import '../../domain/entities/coach_message.dart';
import '../../domain/usecases/ask_coach.dart';

sealed class CoachEvent extends Equatable {
  const CoachEvent();
  @override
  List<Object?> get props => [];
}

final class CoachQuestionSubmitted extends CoachEvent {
  const CoachQuestionSubmitted(this.question, this.context);
  final String question;
  final CoachContext context;
  @override
  List<Object?> get props => [question, context];
}

final class CoachStopRequested extends CoachEvent {
  const CoachStopRequested();
}

final class CoachCleared extends CoachEvent {
  const CoachCleared();
}

class CoachState extends Equatable {
  const CoachState({this.messages = const [], this.generating = false});

  final List<CoachMessage> messages;
  final bool generating;

  CoachState copyWith({List<CoachMessage>? messages, bool? generating}) =>
      CoachState(
        messages: messages ?? this.messages,
        generating: generating ?? this.generating,
      );

  @override
  List<Object?> get props => [messages, generating];
}

/// The coach chat. History lives in memory for the signed-in session (the
/// bloc sits in `UserScope`, so it's dropped on logout).
class CoachBloc extends Bloc<CoachEvent, CoachState> {
  CoachBloc(this._ask) : super(const CoachState()) {
    on<CoachQuestionSubmitted>(_onAsk);
    on<CoachStopRequested>((_, _) => _stop());
    on<CoachCleared>(_onClear);
  }

  final AskCoach _ask;
  Completer<void>? _stopSignal;

  static const offlineMessage =
      "You're offline. Download the on-device model to chat without internet.";
  static const errorMessage = "Couldn't reach the coach right now. Try again.";
  static const emptyMessage =
      "I couldn't come up with an answer. Try rephrasing your question.";

  void _stop() {
    final s = _stopSignal;
    if (s != null && !s.isCompleted) s.complete();
  }

  Future<void> _onAsk(
    CoachQuestionSubmitted event,
    Emitter<CoachState> emit,
  ) async {
    final question = event.question.trim();
    if (question.isEmpty || state.generating) return;

    final history = state.messages;
    final stop = _stopSignal = Completer<void>();
    final buffer = StringBuffer();
    CoachSource? source;

    CoachState withAnswer(String text, {bool failed = false}) => CoachState(
      messages: [
        ...history,
        CoachMessage.user(question),
        CoachMessage(
          role: CoachRole.coach,
          text: text,
          source: source,
          failed: failed,
        ),
      ],
      generating: true,
    );

    emit(withAnswer(''));

    try {
      await emit.forEach<CoachDelta>(
        _until(
          _ask(question: question, context: event.context, history: history),
          stop.future,
        ),
        onData: (d) {
          buffer.write(d.text);
          source = d.source;
          return withAnswer(buffer.toString());
        },
      );
      final text = buffer.toString().trim();
      if (text.isNotEmpty) {
        emit(withAnswer(text).copyWith(generating: false));
      } else if (stop.isCompleted) {
        emit(withAnswer('Stopped.', failed: true).copyWith(generating: false));
      } else {
        emit(
          withAnswer(emptyMessage, failed: true).copyWith(generating: false),
        );
      }
    } catch (e) {
      debugPrint('Coach failed: $e');
      final partial = buffer.toString().trim();
      emit(
        (partial.isNotEmpty
                ? withAnswer(partial)
                : withAnswer(
                    AIInsightsBloc.isOfflineError(e)
                        ? offlineMessage
                        : errorMessage,
                    failed: true,
                  ))
            .copyWith(generating: false),
      );
    } finally {
      if (identical(_stopSignal, stop)) _stopSignal = null;
    }
  }

  Future<void> _onClear(CoachCleared event, Emitter<CoachState> emit) async {
    _stop();
    emit(const CoachState());
  }

  /// Ends [source] (cancelling it, which stops generation) when [stop]
  /// completes.
  static Stream<T> _until<T>(Stream<T> source, Future<void> stop) {
    late final StreamController<T> controller;
    StreamSubscription<T>? sub;
    controller = StreamController<T>(
      onListen: () {
        sub = source.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
        stop.then((_) async {
          await sub?.cancel();
          if (!controller.isClosed) await controller.close();
        });
      },
      onCancel: () => sub?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> close() {
    _stop();
    return super.close();
  }
}
