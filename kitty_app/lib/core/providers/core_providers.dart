import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../services/connectivity_service.dart';
import '../storage/secure_storage_service.dart';
import 'auth_state_provider.dart';

/// Provider for global application configuration.
final Provider<AppConfig> appConfigProvider = Provider<AppConfig>((Ref ref) {
  return AppConfig.instance;
});

/// Provider for bank-grade secure storage service.
final Provider<SecureStorageService> secureStorageServiceProvider =
    Provider<SecureStorageService>((Ref ref) {
  return SecureStorageService();
});

/// Provider for device network connectivity listener service.
final Provider<ConnectivityService> connectivityServiceProvider =
    Provider<ConnectivityService>((Ref ref) {
  return ConnectivityService();
});

/// Stream provider broadcasting boolean online (`true`) / offline (`false`) status.
final StreamProvider<bool> connectivityStatusProvider =
    StreamProvider<bool>((Ref ref) async* {
  final ConnectivityService service = ref.watch(connectivityServiceProvider);
  yield await service.isConnected();
  yield* service.onConnectivityChanged;
});

/// Provider for outgoing authentication Bearer token interceptor.
final Provider<AuthInterceptor> authInterceptorProvider =
    Provider<AuthInterceptor>((Ref ref) {
  final SecureStorageService storage = ref.watch(secureStorageServiceProvider);
  return AuthInterceptor(
    secureStorageService: storage,
    onUnauthorized: () {
      ref.read(appAuthStateProvider.notifier).logout();
    },
  );
});

/// Provider for centralized Dio HTTP client.
final Provider<DioClient> dioClientProvider = Provider<DioClient>((Ref ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  final AuthInterceptor authInterceptor = ref.watch(authInterceptorProvider);
  return DioClient(
    config: config,
    authInterceptor: authInterceptor,
  );
});
