import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/config/app_config.dart';
import 'package:kitty_app/core/config/app_environment.dart';

void main() {
  group('AppConfig & AppEnvironment', () {
    test('resolves mock environment by default', () {
      final AppConfig config = AppConfig(environment: AppEnvironment.mock);
      expect(config.environment, equals(AppEnvironment.mock));
      expect(config.useMockApi, isTrue);
      expect(config.baseUrl, contains('mock.kittyapp.local'));
    });

    test('resolves staging environment', () {
      final AppConfig config = AppConfig(environment: AppEnvironment.staging);
      expect(config.environment, equals(AppEnvironment.staging));
      expect(config.baseUrl, contains('staging-api'));
    });

    test('resolves staging environment with real remote backend when useMockApi is false', () {
      final AppConfig config = AppConfig(
        environment: AppEnvironment.staging,
        baseUrl: 'http://10.0.2.2:5000',
        useMockApi: false,
      );
      expect(config.environment, equals(AppEnvironment.staging));
      expect(config.baseUrl, equals('http://10.0.2.2:5000'));
      expect(config.useMockApi, isFalse);
    });

    test('parses environment strings safely', () {
      expect(AppEnvironment.fromString('dev'), equals(AppEnvironment.dev));
      expect(AppEnvironment.fromString('STAGING'), equals(AppEnvironment.staging));
      expect(AppEnvironment.fromString('prod'), equals(AppEnvironment.prod));
      expect(AppEnvironment.fromString('invalid_env'), equals(AppEnvironment.mock));
      expect(AppEnvironment.fromString(null), equals(AppEnvironment.mock));
    });
  });
}
