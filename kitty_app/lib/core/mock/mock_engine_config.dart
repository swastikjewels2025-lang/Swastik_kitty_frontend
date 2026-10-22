import '../errors/app_exception.dart';

/// Simulated latency profiles for offline mock repositories.
enum MockLatency {
  instant(Duration.zero),
  fast(Duration(milliseconds: 150)),
  normal(Duration(milliseconds: 400)),
  slow(Duration(milliseconds: 1200));

  const MockLatency(this.duration);
  final Duration duration;
}

/// Controlled failure simulation modes for developer testing.
enum MockFailureMode {
  none,
  badRequest400,
  unauthorized401,
  forbidden403,
  notFound404,
  conflict409,
  rateLimit429,
  serverError500,
  timeout,
  networkUnavailable,
}

/// Global configuration and simulation engine for Mock Repositories.
///
/// Enables developers and automated tests to control latency, inject specific
/// HTTP/network failures, and maintain in-memory mutable state across requests.
class MockEngineConfig {
  MockEngineConfig({
    this.latency = MockLatency.fast,
    this.failureMode = MockFailureMode.none,
  });

  MockEngineConfig._()
      : latency = MockLatency.fast,
        failureMode = MockFailureMode.none;

  static final MockEngineConfig instance = MockEngineConfig._();

  /// Current artificial latency mode.
  MockLatency latency;

  /// Current failure injection mode.
  MockFailureMode failureMode;

  /// Resets mock simulation to default healthy fast state.
  void reset() {
    latency = MockLatency.fast;
    failureMode = MockFailureMode.none;
  }

  /// Alias for [simulate].
  Future<void> simulateResponse() => simulate();

  /// Delays execution according to [latency] and throws simulated exceptions if [failureMode] is set.
  Future<void> simulate() async {
    if (latency.duration > Duration.zero) {
      await Future<void>.delayed(latency.duration);
    }

    switch (failureMode) {
      case MockFailureMode.none:
        return;
      case MockFailureMode.badRequest400:
        throw const ValidationException(
          'Simulated 400: Invalid request parameters.',
          'BAD_REQUEST',
          400,
        );
      case MockFailureMode.unauthorized401:
        throw const UnauthorizedException(
          'Simulated 401: Session expired or invalid token.',
        );
      case MockFailureMode.forbidden403:
        throw const ForbiddenException(
          'Simulated 403: KYC verification required to perform this action.',
        );
      case MockFailureMode.notFound404:
        throw const NotFoundException(
          'Simulated 404: The requested resource was not found.',
        );
      case MockFailureMode.conflict409:
        throw const ConflictException(
          'Simulated 409: State conflict or duplicate entry.',
        );
      case MockFailureMode.rateLimit429:
        throw const RateLimitException(
          'Simulated 429: Too many requests. Please slow down.',
        );
      case MockFailureMode.serverError500:
        throw const ServerException(
          'Simulated 500: Internal server error.',
          'SERVER_ERROR',
          500,
        );
      case MockFailureMode.timeout:
        throw const TimeoutException(
          'Simulated Timeout: Network request timed out.',
        );
      case MockFailureMode.networkUnavailable:
        throw const NetworkException(
          'Simulated Network Error: No active internet connection.',
        );
    }
  }
}
