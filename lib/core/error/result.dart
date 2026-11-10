import 'package:fitness_app/core/error/failures.dart';

/// Success or [Failure], returned by repositories instead of throwing.
sealed class Result<T> {
  const Result();

  /// Runs [action], turning any thrown exception into a [Err] via
  /// [Failure.fromException].
  static Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } catch (e) {
      return Err(Failure.fromException(e));
    }
  }

  R fold<R>(R Function(Failure failure) onErr, R Function(T value) onOk) {
    final self = this;
    return switch (self) {
      Ok<T>(:final value) => onOk(value),
      Err<T>(:final failure) => onErr(failure),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
