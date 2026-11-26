import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Failure.fromException maps data-layer errors', () {
    Failure f(Object e) => Failure.fromException(e);

    expect(f(const SocketException('x')), isA<NetworkFailure>());
    expect(f(TimeoutException('x')), isA<TimeoutFailure>());
    expect(f(const ServerException(statusCode: 404)), isA<NotFoundFailure>());
    expect(f(const ServerException(statusCode: 500)), isA<ServerFailure>());
    expect(f(const UnauthenticatedException()), isA<AuthFailure>());
    expect(
      f(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable')),
      isA<NetworkFailure>(),
    );
    expect(
      f(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      ),
      isA<AuthFailure>(),
    );
    expect(f(StateError('boom')), isA<UnknownFailure>());
  });

  test('raw exception text never becomes the message', () {
    final message = Failure.fromException(
      Exception('{"error":"secret"}'),
    ).message;
    expect(message, isNot(contains('secret')));
  });

  test('Result.guard wraps values and failures', () async {
    final ok = await Result.guard(() async => 42);
    final err = await Result.guard<int>(
      () async => throw const SocketException('x'),
    );
    expect(ok.fold((_) => -1, (v) => v), 42);
    expect(err.fold((f) => f, (_) => null), isA<NetworkFailure>());
  });
}
