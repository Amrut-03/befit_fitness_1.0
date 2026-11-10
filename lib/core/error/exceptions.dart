/// Thrown by data sources that need a signed-in user when there isn't one,
/// e.g. a Firestore stream that is still active after logout.
class UnauthenticatedException implements Exception {
  const UnauthenticatedException();

  @override
  String toString() => 'UnauthenticatedException: no signed-in user';
}

/// No connectivity (DNS, socket or connection errors).
class NetworkException implements Exception {
  const NetworkException([this.cause]);
  final Object? cause;

  @override
  String toString() => 'NetworkException($cause)';
}

/// The request didn't complete within the timeout.
class RequestTimeoutException implements Exception {
  const RequestTimeoutException();

  @override
  String toString() => 'RequestTimeoutException';
}

/// The server answered with a non-success status, or an unreadable body.
class ServerException implements Exception {
  const ServerException({this.statusCode, this.message});
  final int? statusCode;
  final String? message;

  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ServerException($statusCode, $message)';
}
