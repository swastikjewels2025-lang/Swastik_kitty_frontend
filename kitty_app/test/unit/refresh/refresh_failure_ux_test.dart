import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:kitty_app/features/dashboard/presentation/providers/dashboard_state.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/offers/presentation/providers/offers_controller.dart';
import 'package:kitty_app/features/offers/presentation/providers/offers_state.dart';
import 'package:kitty_app/features/passbook/data/repositories/mock_passbook_repository.dart';
import 'package:kitty_app/features/passbook/presentation/providers/passbook_controller.dart';
import 'package:kitty_app/features/passbook/presentation/providers/passbook_state.dart';

void main() {
  group('Phase 15 - Refresh Failure UX Suite (Preserve Cached Content)', () {
    final MockEngineConfig instantConfig =
        MockEngineConfig(latency: MockLatency.instant);

    test('1. Dashboard: Refresh failure preserves loaded metrics and populates error message',
        () async {
      final mockRepo = MockDashboardRepository(engineConfig: instantConfig);
      final element = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(element.dispose);

      // Initial load
      final controller = element.read(dashboardControllerProvider.notifier);
      await controller.loadDashboard();

      expect(element.read(dashboardControllerProvider).status,
          equals(DashboardStatus.loaded));
      expect(element.read(dashboardControllerProvider).data, isNotNull);
      final cachedScheme = element.read(dashboardControllerProvider).data!.schemeName;

      // Trigger refresh failure
      mockRepo.setShouldThrow(true);
      await controller.loadDashboard(refresh: true);

      // Data is NOT blown away! Status stays loaded
      final currentState = element.read(dashboardControllerProvider);
      expect(currentState.status, equals(DashboardStatus.loaded));
      expect(currentState.data, isNotNull);
      expect(currentState.data!.schemeName, equals(cachedScheme));
      expect(currentState.errorMessage, isNotNull);
    });

    test('2. Passbook: Refresh failure preserves loaded entries and ledger summary',
        () async {
      final mockRepo = MockPassbookRepository(engineConfig: instantConfig);
      final container = ProviderContainer(
        overrides: [
          passbookRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(passbookControllerProvider.notifier);
      await controller.loadPassbook();

      expect(container.read(passbookControllerProvider).status,
          equals(PassbookStatus.loaded));
      expect(container.read(passbookControllerProvider).entries.isNotEmpty, isTrue);
      final cachedEntryCount =
          container.read(passbookControllerProvider).entries.length;

      // Trigger refresh failure
      mockRepo.setShouldThrow(true);
      await controller.loadPassbook(refresh: true);

      // Existing entries remain visible
      final currentState = container.read(passbookControllerProvider);
      expect(currentState.status, equals(PassbookStatus.loaded));
      expect(currentState.entries.length, equals(cachedEntryCount));
      expect(currentState.errorMessage, isNotNull);
    });

    test('3. Offers: Refresh failure preserves active schemes and catalog products',
        () async {
      final mockSchemeRepo = MockSchemeRepository(engineConfig: instantConfig);
      final container = ProviderContainer(
        overrides: [
          schemeRepositoryProvider.overrideWithValue(mockSchemeRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(offersControllerProvider.notifier);
      await controller.loadOffersAndCatalog();

      expect(container.read(offersControllerProvider).status,
          equals(OffersStatus.loaded));
      expect(container.read(offersControllerProvider).schemes.isNotEmpty, isTrue);
      final cachedSchemeCount =
          container.read(offersControllerProvider).schemes.length;

      // Trigger refresh failure
      mockSchemeRepo.setShouldThrow(true);
      await controller.loadOffersAndCatalog(refresh: true);

      // Existing schemes remain visible
      final currentState = container.read(offersControllerProvider);
      expect(currentState.status, equals(OffersStatus.loaded));
      expect(currentState.schemes.length, equals(cachedSchemeCount));
      expect(currentState.errorMessage, isNotNull);
    });
  });
}
