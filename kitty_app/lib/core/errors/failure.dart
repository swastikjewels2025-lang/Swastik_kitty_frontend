import 'app_exception.dart';

/// UI-facing immutable failure representation for presentation layer widgets.
sealed class Failure {
  const Failure({
    required this.message,
    this.code,
    this.exception,
  });

  /// User-friendly message suitable for snackbars, toasts, or error cards.
  final String message;

  /// Optional error code string for telemetry or specialized UI branching.
  final String? code;

  /// Underlying source exception if available.
  final AppException? exception;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Network connectivity failure.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please verify your network.',
    super.code = 'NETWORK_FAILURE',
    super.exception,
  });
}

/// Request timeout failure.
final class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'The request took too long. Please try again.',
    super.code = 'TIMEOUT_FAILURE',
    super.exception,
  });
}

/// Authentication / Session failure.
final class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed or session expired. Please log in.',
    super.code = 'AUTH_FAILURE',
    super.exception,
  });
}

/// Form input or domain rule validation failure.
final class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_FAILURE',
    super.exception,
  });
}

/// Server or gateway outage failure.
final class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred. Our engineers have been notified.',
    super.code = 'SERVER_FAILURE',
    super.exception,
  });
}

/// General fallback failure.
final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Something went wrong. Please try again.',
    super.code = 'UNKNOWN_FAILURE',
    super.exception,
  });
}
