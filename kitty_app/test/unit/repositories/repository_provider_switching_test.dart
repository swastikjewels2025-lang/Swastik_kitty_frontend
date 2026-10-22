import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/config/app_config.dart';
import 'package:kitty_app/core/config/app_environment.dart';
import 'package:kitty_app/core/providers/core_providers.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:kitty_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kitty_app/features/kyc/data/repositories/mock_kyc_repository.dart';
import 'package:kitty_app/features/kyc/data/repositories/kyc_repository_impl.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/offers/data/repositories/scheme_repository_impl.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues(<String, String>{});

  group('Repository Provider Dynamic Switching Tests', () {
    test('Injects Mock Repositories when useMockApi is true', () {
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(
              environment: AppEnvironment.mock,
              useMockApi: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final authRepo = container.read(authRepositoryProvider);
      expect(authRepo, isA<MockAuthRepository>());

      final kycRepo = container.read(kycRepositoryProvider);
      expect(kycRepo, isA<MockKycRepository>());

      final schemeRepo = container.read(schemeRepositoryProvider);
      expect(schemeRepo, isA<MockSchemeRepository>());

      final dashRepo = container.read(dashboardRepositoryProvider);
      expect(dashRepo, isA<MockDashboardRepository>());
    });

    test('Injects Remote Repository Implementations when useMockApi is false', () {
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(
              environment: AppEnvironment.dev,
              useMockApi: false,
              baseUrl: 'http://localhost:5000',
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final authRepo = container.read(authRepositoryProvider);
      expect(authRepo, isA<AuthRepositoryImpl>());

      final kycRepo = container.read(kycRepositoryProvider);
      expect(kycRepo, isA<KycRepositoryImpl>());

      final schemeRepo = container.read(schemeRepositoryProvider);
      expect(schemeRepo, isA<SchemeRepositoryImpl>());

      final dashRepo = container.read(dashboardRepositoryProvider);
      expect(dashRepo, isA<DashboardRepositoryImpl>());
    });
  });
}
