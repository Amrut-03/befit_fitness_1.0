import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fitness_app/core/config/app_config.dart';
import 'package:fitness_app/core/error/exceptions.dart';
import 'package:http/http.dart' as http;

/// Shared HTTP client for third-party APIs: sets the User-Agent, applies a
/// timeout, and maps transport errors to typed exceptions
/// ([NetworkException], [RequestTimeoutException], [ServerException]).
class ApiClient {
  ApiClient({http.Client? client, this.timeout = AppConfig.httpTimeout})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  /// GETs [uri] and decodes a JSON object body.
  ///
  /// Throws [ServerException] for non-2xx responses (check `isNotFound`).
  Future<Map<String, dynamic>> getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'User-Agent': AppConfig.userAgent})
          .timeout(timeout);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on SocketException catch (e) {
      throw NetworkException(e);
    } on http.ClientException catch (e) {
      throw NetworkException(e);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException(statusCode: response.statusCode);
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // fall through
    }
    throw ServerException(
      statusCode: response.statusCode,
      message: 'Invalid JSON',
    );
  }
}
