import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/network/interceptors/error_interceptor.dart';

void main() {
  group('ErrorInterceptor Mapping', () {
    test('maps connection timeout to TimeoutException', () {
      final DioException dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      final AppException result = ErrorInterceptor.mapDioExceptionToAppException(dioException);
      expect(result, isA<TimeoutException>());
    });

    test('maps connection error to NetworkException', () {
      final DioException dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      final AppException result = ErrorInterceptor.mapDioExceptionToAppException(dioException);
      expect(result, isA<NetworkException>());
    });

    test('maps HTTP 401 to UnauthorizedException', () {
      final DioException dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: <String, dynamic>{
            'success': false,
            'message': 'Token expired',
            'error': <String, dynamic>{
              'code': 'EXPIRED_JWT',
            },
          },
        ),
      );
      final AppException result = ErrorInterceptor.mapDioExceptionToAppException(dioException);
      expect(result, isA<UnauthorizedException>());
      expect(result.message, equals('Token expired'));
      expect(result.code, equals('EXPIRED_JWT'));
    });

    test('maps HTTP 403 to ForbiddenException', () {
      final DioException dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
          data: <String, dynamic>{
            'success': false,
            'message': 'KYC Required',
            'error': <String, dynamic>{
              'code': 'KYC_NOT_VERIFIED',
            },
          },
        ),
      );
      final AppException result = ErrorInterceptor.mapDioExceptionToAppException(dioException);
      expect(result, isA<ForbiddenException>());
    });

    test('maps HTTP 400 to ValidationException', () {
      final DioException dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: <String, dynamic>{
            'success': false,
            'message': 'Invalid phone number',
            'error': <String, dynamic>{
              'code': 'INVALID_PHONE',
            },
          },
        ),
      );
      final AppException result = ErrorInterceptor.mapDioExceptionToAppException(dioException);
      expect(result, isA<ValidationException>());
    });

    test('maps HTTP 500 to ServerException', () {
      final DioException dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );
      final AppException result = ErrorInterceptor.mapDioExceptionToAppException(dioException);
      expect(result, isA<ServerException>());
    });
  });
}
