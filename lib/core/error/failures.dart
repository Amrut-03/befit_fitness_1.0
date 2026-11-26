import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:http/http.dart' as http;

/// A failure the UI can show. Repositories return these in a [Result]
/// (or blocs map caught exceptions with [Failure.fromException]) so raw
/// exception text (`e.toString()`) never reaches users.
sealed class Failure {
  const Failure([this._custom]);

  final String? _custom;

  /// User-facing message, in the app's current language unless a custom
  /// message was given.
  String get message => _custom ?? defaultMessage(AppLocale.l10n);

  String defaultMessage(AppLocalizations l10n);

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
  const NetworkFailure([super._custom]);
  @override
  String defaultMessage(AppLocalizations l10n) => l10n.failureNetwork;
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super._custom]);
  @override
  String defaultMessage(AppLocalizations l10n) => l10n.failureTimeout;
}

class ServerFailure extends Failure {
  const ServerFailure([super._custom]);
  @override
  String defaultMessage(AppLocalizations l10n) => l10n.failureServer;
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super._custom]);
  @override
  String defaultMessage(AppLocalizations l10n) => l10n.failureNotFound;
}

class AuthFailure extends Failure {
  const AuthFailure([super._custom]);
  @override
  String defaultMessage(AppLocalizations l10n) => l10n.failureAuth;
}

class UnknownFailure extends Failure {
  const UnknownFailure([super._custom]);
  @override
  String defaultMessage(AppLocalizations l10n) => l10n.commonSomethingWentWrong;
}
