import 'package:fitness_app/core/error/exceptions.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/error/result.dart';
import 'package:fitness_app/features/food_scanner/data/datasources/remote/food_scanner_remote_datasource.dart';
import 'package:fitness_app/features/food_scanner/data/repositories/food_scanner_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements FoodScannerRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late FoodScannerRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    repo = FoodScannerRepositoryImpl(remote);
  });

  test('unknown barcode is Ok(null), not an error', () async {
    when(() => remote.getFoodByBarcode('0')).thenAnswer((_) async => null);

    final result = await repo.scanBarcode('0');

    expect(result, isA<Ok<Object?>>());
    expect((result as Ok).value, isNull);
  });

  final cases = <String, (Object, Type)>{
    'no connection': (const NetworkException(), NetworkFailure),
    'timeout': (const RequestTimeoutException(), TimeoutFailure),
    'server error': (const ServerException(statusCode: 503), ServerFailure),
    'unexpected': (StateError('boom'), UnknownFailure),
  };

  cases.forEach((name, c) {
    test('$name maps to ${c.$2}', () async {
      when(() => remote.getFoodByBarcode(any())).thenThrow(c.$1);

      final result = await repo.scanBarcode('123');

      expect(result, isA<Err<Object?>>());
      final failure = (result as Err).failure;
      expect(failure.runtimeType, c.$2);
      expect(failure.message, isNot(contains('Exception')));
    });
  });
}
