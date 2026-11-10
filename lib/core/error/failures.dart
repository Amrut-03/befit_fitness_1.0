import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:fitness_app/core/error/exceptions.dart';
import 'package:http/http.dart' as http;

/// A failure the UI can show. Repositories return these in a [Result]
/// (or blocs map caught exceptions with [Failure.fromException]) so raw
/// exception text (`e.toString()`) never reaches users.
sealed class Failure {
  const Failure(this.message);

  /// User-facing message.
  final String message;

  /// Maps any exception from the data layer to a [Failure].
  factory Failure.fromException(Object e) {
    if (e is Failure) return e;
    if (e is UnauthenticatedException) return const AuthFailure();
    if (e is NetworkException ||
        e is SocketException ||
        e is http.ClientException) {
      return const NetworkFailure();
    }
    if (e is RequestTimeoutException || e is TimeoutException) {
      return const TimeoutFailure();
    }
    if (e is ServerException) {
      return e.isNotFound ? const NotFoundFailure() : const ServerFailure();
    }
    if (e is FirebaseException) {
      switch (e.code) {
        case 'unavailable':
        case 'network-request-failed':
          return const NetworkFailure();
        case 'deadline-exceeded':
          return const TimeoutFailure();
        case 'permission-denied':
        case 'unauthenticated':
          return const AuthFailure();
        case 'not-found':
          return const NotFoundFailure();
      }
      return const ServerFailure();
    }
    return const UnknownFailure();
  }

  @override
  String toString() => '$runtimeType($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'No internet connection. Check your connection and try '
        'again.',
  ]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'This is taking too long. Please try again.',
  ]);
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'The service is unavailable right now. Please try again.',
  ]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = "We couldn't find that."]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Please sign in again.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
