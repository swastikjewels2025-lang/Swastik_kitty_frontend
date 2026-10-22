import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:kitty_app/features/home/data/repositories/mock_gold_rate_repository.dart';

void main() {
  late MockEngineConfig engineConfig;

  setUp(() {
    engineConfig = MockEngineConfig(latency: MockLatency.instant);
  });

  group('Mock Failure Simulation Engine Tests', () {
    test('Simulates 400 Bad Request', () async {
      engineConfig.failureMode = MockFailureMode.badRequest400;
      final repo = MockGoldRateRepository(engineConfig: engineConfig);

      expect(() => repo.getLiveGoldRate(), throwsA(isA<ValidationException>()));
    });

    test('Simulates 401 Unauthorized', () async {
      engineConfig.failureMode = MockFailureMode.unauthorized401;
      final repo = MockGoldRateRepository(engineConfig: engineConfig);

      expect(() => repo.getLiveGoldRate(), throwsA(isA<UnauthorizedException>()));
    });

    test('Simulates 403 Forbidden', () async {
      engineConfig.failureMode = MockFailureMode.forbidden403;
      final repo = MockGoldRateRepository(engineConfig: engineConfig);

      expect(() => repo.getLiveGoldRate(), throwsA(isA<ForbiddenException>()));
    });

    test('Simulates 404 Not Found', () async {
      engineConfig.failureMode = MockFailureMode.notFound404;
      final repo = MockGoldRateRepository(engineConfig: engineConfig);

      expect(() => repo.getLiveGoldRate(), throwsA(isA<NotFoundException>()));
    });

    test('Simulates 409 Conflict', () async {
      engineConfig.failureMode = MockFailureMode.conflict409;
      final repo = MockGoldRateRepository(engineConfig: engineConfig);

      expect(() => repo.getLiveGoldRate(), throwsA(isA<ConflictException>()));
    });

    test('Simulates 429 Rate Limit', () async {
      engineConfig.failureMode = MockFailureMode.rateLimit429;
      final repo = MockAuthRepository(engineConfig: engineConfig);

      expect(() => repo.sendOtp(phone: '+919876543210'), throwsA(isA<RateLimitException>()));
    });

    test('Simulates 500 Server Error', () async {
      engineConfig.failureMode = MockFailureMode.serverError500;
      final repo = MockGoldRateRepository(engineConfig: engineConfig);

      expect(() => repo.getLiveGoldRate(), throwsA(isA<ServerException>()));
    });

    test('Simulates Timeout Exception', () async {
      engineConfig.failureMode = MockFailureMode.timeout;
      final repo = MockGoldRateRepository(engineConfig: engineConfig);

      expect(() => repo.getLiveGoldRate(), throwsA(isA<TimeoutException>()));
    });

    test('Simulates Network Unavailable', () async {
      engineConfig.failureMode = MockFailureMode.networkUnavailable;
      final repo = MockGoldRateRepository(engineConfig: engineConfig);

      expect(() => repo.getLiveGoldRate(), throwsA(isA<NetworkException>()));
    });
  });
}
