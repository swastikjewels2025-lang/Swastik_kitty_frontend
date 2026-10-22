import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:kitty_app/features/home/data/repositories/mock_gold_rate_repository.dart';
import 'package:kitty_app/features/home/data/repositories/mock_product_repository.dart';
import 'package:kitty_app/features/home/presentation/providers/home_controller.dart';
import 'package:kitty_app/features/home/presentation/providers/home_state.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';

void main() {
  group('HomeController Unit Tests', () {
    late ProviderContainer container;
    late MockEngineConfig instantConfig;

    setUp(() {
      instantConfig = MockEngineConfig(latency: MockLatency.instant);
      container = ProviderContainer(
        overrides: [
          mockEngineConfigProvider.overrideWithValue(instantConfig),
          goldRateRepositoryProvider.overrideWithValue(
            MockGoldRateRepository(engineConfig: instantConfig),
          ),
          productRepositoryProvider.overrideWithValue(
            MockProductRepository(engineConfig: instantConfig),
          ),
          schemeRepositoryProvider.overrideWithValue(
            MockSchemeRepository(engineConfig: instantConfig),
          ),
          dashboardRepositoryProvider.overrideWithValue(
            MockDashboardRepository(engineConfig: instantConfig),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial build triggers loadHomeData and transitions to loaded', () async {
      final controller = container.read(homeControllerProvider.notifier);
      
      // Initially loading
      expect(container.read(homeControllerProvider).status, HomeStatus.loading);

      // Await load completion
      await controller.loadHomeData();

      final state = container.read(homeControllerProvider);
      expect(state.status, HomeStatus.loaded);
      expect(state.data, isNotNull);
      expect(state.data!.goldRate, isNotNull);
      expect(state.data!.goldRate!.ratePerGram, 15268.000);
      expect(state.data!.curatedProducts, isNotEmpty);
      expect(state.data!.schemes, isNotEmpty);
      expect(state.data!.activeKitty, isNotNull);
      expect(state.data!.activeKitty!.chitToken, '#SW-042');
    });

    test('selectCategory updates selectedCategory and filters products', () async {
      final controller = container.read(homeControllerProvider.notifier);
      await controller.loadHomeData();

      expect(container.read(homeControllerProvider).data!.selectedCategory, 'All');
      final allCount = container.read(homeControllerProvider).data!.filteredProducts.length;
      expect(allCount, greaterThan(0));

      // Select 'Diamond Rings'
      controller.selectCategory('Diamond Rings');

      final state = container.read(homeControllerProvider);
      expect(state.data!.selectedCategory, 'Diamond Rings');
      expect(
        state.data!.filteredProducts.every((p) => p.category == 'Diamond Rings'),
        isTrue,
      );
      expect(state.data!.filteredProducts.length, lessThanOrEqualTo(allCount));
    });

    test('refresh preserves existing data and updates state', () async {
      final controller = container.read(homeControllerProvider.notifier);
      await controller.loadHomeData();

      expect(container.read(homeControllerProvider).status, HomeStatus.loaded);

      // Trigger refresh
      await controller.refresh();

      final state = container.read(homeControllerProvider);
      expect(state.status, HomeStatus.loaded);
      expect(state.data, isNotNull);
      expect(state.errorMessage, isNull);
    });
  });
}
