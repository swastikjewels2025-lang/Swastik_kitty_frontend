import 'package:dio/dio.dart';
import '../../storage/secure_storage_service.dart';

/// Authentication interceptor injecting Bearer JWT token into outgoing requests.
///
/// Follows Frozen Backend Contract v1.0:
/// - Single 30-day JWT.
/// - Injects `Authorization: Bearer <JWT>`.
/// - Dispatches [onUnauthorized] event on HTTP 401 to trigger clean session purge.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.secureStorageService,
    this.onUnauthorized,
  });

  final SecureStorageService secureStorageService;

  /// Optional session expiration callback invoked when receiving an HTTP 401.
  final void Function()? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if token already manually provided in options
    if (!options.headers.containsKey('Authorization')) {
      final String? token = await secureStorageService.getToken();
      if (token != null && token.trim().isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Notify session listener to purge token and session cache
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
