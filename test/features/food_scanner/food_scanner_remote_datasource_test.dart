import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fitness_app/core/config/app_config.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/error/result.dart';
import 'package:fitness_app/core/network/api_client.dart';
import 'package:fitness_app/features/food_scanner/data/datasources/remote/food_scanner_remote_datasource.dart';
import 'package:fitness_app/features/food_scanner/data/repositories/food_scanner_repository_impl.dart';
import 'package:fitness_app/features/food_scanner/domain/entities/scanned_food_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  FoodScannerRemoteDataSource ds(MockClientHandler h) =>
      FoodScannerRemoteDataSource(api: ApiClient(client: MockClient(h)));

  Future<Result<FoodItemEntity?>> scan(MockClientHandler h) =>
      FoodScannerRepositoryImpl(ds(h)).scanBarcode('1');

  Failure? failureOf(Result<FoodItemEntity?> r) =>
      r.fold((f) => f, (_) => null);

  test('calls v2 with fields and a User-Agent, parses the product', () async {
    late http.Request sent;
    final result = await ds((req) async {
      sent = req;
      return http.Response(
        jsonEncode({
          'code': '3017624010701',
          'status': 1,
          'product': {
            'product_name': '',
            'product_name_en': 'Nutella',
            'brands': 'Ferrero',
            'nutriments': {
              'energy-kcal_100g': 539,
              'proteins_100g': 6.3,
              'carbohydrates_100g': '57.5',
              'fat_100g': 30.9,
            },
          },
        }),
        200,
      );
    }).getFoodByBarcode('3017624010701');

    expect(sent.url.path, '/api/v2/product/3017624010701');
    expect(sent.url.queryParameters['fields'], contains('nutriments'));
    expect(sent.headers['User-Agent'], AppConfig.userAgent);

    expect(result!.name, 'Nutella', reason: 'falls back past empty name');
    expect(result.calories, 539);
    expect(result.carbs, 57.5);
  });

  test('kJ-only energy is converted to kcal', () async {
    final result = await ds(
      (_) async => http.Response(
        jsonEncode({
          'code': '1',
          'status': 1,
          'product': {
            'product_name': 'Oats',
            'nutriments': {'energy_100g': 1548},
          },
        }),
        200,
      ),
    ).getFoodByBarcode('1');
    expect(result!.calories, closeTo(370, 0.1));
  });

  test('unknown barcode (404 or status 0) → Ok(null)', () async {
    for (final code in [404, 200]) {
      final r = await scan((_) async => http.Response('{"status":0}', code));
      expect(r.fold((_) => 'err', (v) => v), isNull);
    }
  });

  test('offline → NetworkFailure', () async {
    final r = await scan((_) async => throw const SocketException('no route'));
    expect(failureOf(r), isA<NetworkFailure>());
  });

  test('timeout → TimeoutFailure', () async {
    final r = await scan((_) async => throw TimeoutException('slow'));
    expect(failureOf(r), isA<TimeoutFailure>());
  });

  test('5xx → ServerFailure', () async {
    final r = await scan((_) async => http.Response('oops', 503));
    expect(failureOf(r), isA<ServerFailure>());
  });
}
