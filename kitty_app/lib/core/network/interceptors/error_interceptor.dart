import 'package:dio/dio.dart';
import '../../errors/app_exception.dart';

/// Centralized Dio error interceptor transforming HTTP and network failures into [AppException].
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final AppException appException = mapDioExceptionToAppException(err);

    // Pass wrapped exception in DioException error property
    final DioException wrappedError = err.copyWith(
      error: appException,
      message: appException.message,
    );

    handler.next(wrappedError);
  }

  /// Pure mapping logic exposed for unit testing.
  static AppException mapDioExceptionToAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final Response<dynamic>? response = err.response;
        final int statusCode = response?.statusCode ?? 500;
        final dynamic responseData = response?.data;

        String? serverMessage;
        String? errorCode;
        Map<String, dynamic>? errorDetails;

        if (responseData is Map<String, dynamic>) {
          serverMessage = responseData['message'] as String?;
          final dynamic errorObj = responseData['error'];
          if (errorObj is Map<String, dynamic>) {
            errorCode = errorObj['code'] as String?;
            errorDetails = errorObj['details'] as Map<String, dynamic>?;
          }
        }

        return _mapHttpStatus(
          statusCode: statusCode,
          serverMessage: serverMessage,
          errorCode: errorCode,
          errorDetails: errorDetails,
        );

      case DioExceptionType.cancel:
        return const UnknownException('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException('Invalid SSL certificate detected.');

      case DioExceptionType.unknown:
      default:
        return UnknownException(err.message ?? 'An unexpected network error occurred.');
    }
  }

  static AppException _mapHttpStatus({
    required int statusCode,
    String? serverMessage,
    String? errorCode,
    Map<String, dynamic>? errorDetails,
  }) {
    switch (statusCode) {
      case 400:
        return ValidationException(
          serverMessage ?? 'Invalid request parameters.',
          errorCode,
          400,
          errorDetails,
        );
      case 401:
        return UnauthorizedException(
          serverMessage ?? 'Your session has expired. Please log in again.',
          errorCode,
          errorDetails,
        );
      case 403:
        return ForbiddenException(
          serverMessage ?? 'You do not have permission to perform this action.',
          errorCode,
          errorDetails,
        );
      case 404:
        return NotFoundException(
          serverMessage ?? 'The requested resource was not found.',
          errorCode,
        );
      case 409:
        return ConflictException(
          serverMessage ?? 'A state conflict occurred. Please retry.',
          errorCode,
          errorDetails,
        );
      case 422:
        return ValidationException(
          serverMessage ?? 'Validation failed for input data.',
          errorCode,
          422,
          errorDetails,
        );
      case 429:
        return RateLimitException(
          serverMessage ?? 'Too many requests. Please wait a moment before trying again.',
          errorCode,
        );
      case 500:
      case 502:
      case 503:
      default:
        return ServerException(
          serverMessage ?? 'Our servers are currently undergoing maintenance. Please try again shortly.',
          errorCode,
          statusCode,
        );
    }
  }
}
