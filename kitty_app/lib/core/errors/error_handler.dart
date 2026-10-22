import 'app_exception.dart';
import 'failure.dart';

/// Global translator converting raw exceptions and errors into typed [Failure] objects.
abstract final class ErrorHandler {
  /// Maps any caught dynamic error or exception to a UI-facing [Failure].
  static Failure handle(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return switch (error) {
        NetworkException() => NetworkFailure(
            message: error.message,
            code: error.code,
            exception: error,
          ),
        TimeoutException() => TimeoutFailure(
            message: error.message,
            code: error.code,
            exception: error,
          ),
        UnauthorizedException() => AuthFailure(
            message: error.message,
            code: error.code,
            exception: error,
          ),
        ForbiddenException() => AuthFailure(
            message: error.message,
            code: error.code,
            exception: error,
          ),
        NotFoundException() => UnknownFailure(
            message: error.message,
            code: error.code,
            exception: error,
          ),
        ConflictException() => ValidationFailure(
            message: error.message,
            code: error.code,
            exception: error,
          ),
        ValidationException() => ValidationFailure(
            message: error.message,
            code: error.code,
            exception: error,
          ),
        RateLimitException() => ValidationFailure(
            message: error.message,
            code: error.code,
            exception: error,
          ),
        ServerException() => ServerFailure(
            message: error.message,
            code: error.code,
            exception: error,
          ),
        UnknownException() => UnknownFailure(
            message: error.message,
            code: error.code,
            exception: error,
          ),
      };
    }

    // Fallback for non-AppException errors: Never expose raw exceptions or URLs
    return const UnknownFailure(
      message: 'Something went wrong. Please try again.',
    );
  }
}
