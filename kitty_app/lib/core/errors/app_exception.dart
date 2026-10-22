/// Base exception class for all domain and infrastructure errors in Kitty App.
sealed class AppException implements Exception {
  const AppException(this.message, {this.code, this.statusCode, this.details});

  /// Human-readable error explanation.
  final String message;

  /// Optional backend error code string (e.g. `INVALID_OTP`, `EXPIRED_TOKEN`).
  final String? code;

  /// HTTP status code if originated from network.
  final int? statusCode;

  /// Structured error details map from backend envelope.
  final Map<String, dynamic>? details;

  @override
  String toString() => '$runtimeType: $message (code: $code, status: $statusCode)';
}

/// Dispatched when internet connection is unreachable.
final class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Unable to connect to the server. Please check your internet connection.',
  ]) : super(code: 'NETWORK_UNAVAILABLE');
}

/// Dispatched when HTTP connection or receive timeout exceeds limits (>15s).
final class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'The request timed out. Please try again.',
  ]) : super(code: 'REQUEST_TIMEOUT');
}

/// Dispatched on HTTP 401 Unauthorized (invalid JWT or expired session).
final class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Your session has expired. Please log in again.',
    String? code,
    Map<String, dynamic>? details,
  ]) : super(code: code ?? 'UNAUTHORIZED', statusCode: 401, details: details);
}

/// Dispatched on HTTP 403 Forbidden (missing permissions or KYC required).
final class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'You do not have permission to perform this action.',
    String? code,
    Map<String, dynamic>? details,
  ]) : super(code: code ?? 'FORBIDDEN', statusCode: 403, details: details);
}

/// Dispatched on HTTP 404 Not Found.
final class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
    String? code,
  ]) : super(code: code ?? 'NOT_FOUND', statusCode: 404);
}

/// Dispatched on HTTP 409 Conflict (e.g. double payment or state clash).
final class ConflictException extends AppException {
  const ConflictException([
    super.message = 'A conflicting operation is already in progress.',
    String? code,
    Map<String, dynamic>? details,
  ]) : super(code: code ?? 'CONFLICT', statusCode: 409, details: details);
}

/// Dispatched on HTTP 400 Bad Request or HTTP 422 Unprocessable Entity.
final class ValidationException extends AppException {
  const ValidationException([
    super.message = 'Please check the entered details and try again.',
    String? code,
    int? statusCode,
    Map<String, dynamic>? details,
  ]) : super(code: code ?? 'VALIDATION_ERROR', statusCode: statusCode ?? 400, details: details);
}

/// Dispatched on HTTP 429 Rate Limited (e.g. SMS OTP spam throttle).
final class RateLimitException extends AppException {
  const RateLimitException([
    super.message = 'Too many requests. Please wait before trying again.',
    String? code,
  ]) : super(code: code ?? 'RATE_LIMITED', statusCode: 429);
}

/// Dispatched on HTTP 500, 502, 503 Server / Gateway Errors.
final class ServerException extends AppException {
  const ServerException([
    super.message = 'Our servers are currently undergoing maintenance. Please try again shortly.',
    String? code,
    int? statusCode,
  ]) : super(code: code ?? 'SERVER_ERROR', statusCode: statusCode ?? 500);
}

/// Dispatched for unexpected runtime or parsing failures.
final class UnknownException extends AppException {
  const UnknownException([
    super.message = 'An unexpected error occurred. Please try again.',
    String? code,
    Map<String, dynamic>? details,
  ]) : super(code: code ?? 'UNKNOWN_ERROR', details: details);
}
