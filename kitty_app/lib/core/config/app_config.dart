import 'app_constants.dart';
import 'app_environment.dart';
import 'server_ip.dart';

/// Centralized configuration service for Kitty App.
///
/// Default configuration:
/// - Connects to local Node.js backend using IP from `server_ip.dart`
/// - `useMockApi` is `false` by default
///
/// Can still be overridden via `--dart-define` if needed:
/// - `BASE_URL`: API root URI override
/// - `USE_MOCK_API`: Explicit boolean flag to force mock data
class AppConfig {
  AppConfig._({
    required this.environment,
    required this.baseUrl,
    required this.useMockApi,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
  });

  /// Factory constructor initializing from environment or defaults.
  factory AppConfig({
    AppEnvironment? environment,
    String? baseUrl,
    bool? useMockApi,
  }) {
    // Default to dev environment with live backend connection
    const String defaultEnv = 'dev';

    // Read from --dart-define or fallback
    const String envString = String.fromEnvironment('ENVIRONMENT', defaultValue: '');
    final String resolvedEnvString = envString.isNotEmpty ? envString : defaultEnv;

    const String baseUrlDefine = String.fromEnvironment('BASE_URL', defaultValue: '');
    const bool useMockApiDefine = bool.fromEnvironment('USE_MOCK_API', defaultValue: false);

    final AppEnvironment resolvedEnv = environment ?? AppEnvironment.fromString(resolvedEnvString);

    final String resolvedBaseUrl = baseUrl ??
        (baseUrlDefine.isNotEmpty
            ? baseUrlDefine
            : _resolveDefaultBaseUrl(resolvedEnv));

    final bool resolvedMock = useMockApi ?? useMockApiDefine;

    return AppConfig._(
      environment: resolvedEnv,
      baseUrl: resolvedBaseUrl,
      useMockApi: resolvedMock,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
    );
  }

  /// Active environment profile.
  final AppEnvironment environment;

  /// API base URL for network calls.
  final String baseUrl;

  /// Whether repositories should use offline mock fixtures.
  final bool useMockApi;

  /// HTTP connect timeout.
  final Duration connectTimeout;

  /// HTTP receive timeout.
  final Duration receiveTimeout;

  /// HTTP send timeout.
  final Duration sendTimeout;

  // ---------------------------------------------------------------------------
  // Global Singleton Instance
  // ---------------------------------------------------------------------------

  static AppConfig? _instance;

  /// Access global initialized config.
  static AppConfig get instance {
    _instance ??= AppConfig();
    return _instance!;
  }

  /// Initialize global config explicitly (e.g. in main.dart).
  static void initialize({
    AppEnvironment? environment,
    String? baseUrl,
    bool? useMockApi,
  }) {
    _instance = AppConfig(
      environment: environment,
      baseUrl: baseUrl,
      useMockApi: useMockApi,
    );
  }

  // ---------------------------------------------------------------------------
  // Internal Helpers
  // ---------------------------------------------------------------------------

  static String _resolveDefaultBaseUrl(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.mock:
      case AppEnvironment.dev:
      case AppEnvironment.prod:
        return kDefaultBaseUrl;
      case AppEnvironment.staging:
        return 'https://staging-api.swastikjewel.com';
    }
  }

  @override
  String toString() {
    return 'AppConfig(env: ${environment.name}, baseUrl: $baseUrl, mock: $useMockApi)';
  }
}
