import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/home/data/repositories/mock_product_repository.dart';
import 'package:kitty_app/features/home/domain/entities/product_entity.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/offers/domain/entities/scheme_entity.dart';
import 'package:kitty_app/features/offers/presentation/providers/offers_controller.dart';
import 'package:kitty_app/features/offers/presentation/providers/offers_state.dart';

void main() {
  group('OffersController Unit Tests', () {
    final MockEngineConfig instantConfig =
        MockEngineConfig(latency: MockLatency.instant);

    late MockSchemeRepository mockSchemeRepo;
    late MockProductRepository mockProductRepo;
    late ProviderContainer container;

    setUp(() {
      mockSchemeRepo = MockSchemeRepository(engineConfig: instantConfig);
      mockProductRepo = MockProductRepository(engineConfig: instantConfig);

      container = ProviderContainer(
        overrides: [
          schemeRepositoryProvider.overrideWithValue(mockSchemeRepo),
          productRepositoryProvider.overrideWithValue(mockProductRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('1. Initial build triggers loadOffersAndCatalog and transitions to loaded state', () async {
      // Read controller to trigger build
      final OffersController controller =
          container.read(offersControllerProvider.notifier);

      // Wait for microtask load to complete
      await controller.loadOffersAndCatalog();

      final OffersState state = container.read(offersControllerProvider);
      expect(state.status, OffersStatus.loaded);
      expect(state.schemes, isNotEmpty);
      expect(state.curatedProducts, isNotEmpty);
      expect(state.categories, contains('All'));
    });

    test('2. setDurationFilter filters schemes correctly', () async {
      final OffersController controller =
          container.read(offersControllerProvider.notifier);
      await controller.loadOffersAndCatalog();

      // Initially All
      expect(container.read(offersControllerProvider).selectedDuration, isNull);
      final int totalCount =
          container.read(offersControllerProvider).filteredSchemes.length;

      // Filter by 12 months
      controller.setDurationFilter(12);
      expect(container.read(offersControllerProvider).selectedDuration, 12);
      for (final SchemeEntity s
          in container.read(offersControllerProvider).filteredSchemes) {
        expect(s.durationMonths, 12);
      }

      // Reset filter
      controller.setDurationFilter(null);
      expect(
        container.read(offersControllerProvider).filteredSchemes.length,
        totalCount,
      );
    });

    test('3. setCategoryFilter filters products correctly', () async {
      final OffersController controller =
          container.read(offersControllerProvider.notifier);
      await controller.loadOffersAndCatalog();

      // Filter by Diamond Rings
      controller.setCategoryFilter('Diamond Rings');
      expect(container.read(offersControllerProvider).selectedCategory, 'Diamond Rings');

      for (final ProductEntity p
          in container.read(offersControllerProvider).filteredProducts) {
        expect(p.category.toLowerCase(), 'diamond rings');
      }

      // Reset to All
      controller.setCategoryFilter('All');
      expect(
        container.read(offersControllerProvider).filteredProducts.length,
        container.read(offersControllerProvider).curatedProducts.length,
      );
    });

    test('4. setSection toggles between schemes and catalog view sections', () async {
      final OffersController controller =
          container.read(offersControllerProvider.notifier);
      await controller.loadOffersAndCatalog();

      expect(
        container.read(offersControllerProvider).activeSection,
        OffersViewSection.schemes,
      );

      controller.setSection(OffersViewSection.catalog);
      expect(
        container.read(offersControllerProvider).activeSection,
        OffersViewSection.catalog,
      );

      controller.setSection(OffersViewSection.schemes);
      expect(
        container.read(offersControllerProvider).activeSection,
        OffersViewSection.schemes,
      );
    });

    test('5. toggleWishlist adds and removes product IDs from local wishlist', () async {
      final OffersController controller =
          container.read(offersControllerProvider.notifier);
      await controller.loadOffersAndCatalog();

      expect(container.read(offersControllerProvider).isWishlisted('prod_01'), isFalse);

      controller.toggleWishlist('prod_01');
      expect(container.read(offersControllerProvider).isWishlisted('prod_01'), isTrue);

      controller.toggleWishlist('prod_01');
      expect(container.read(offersControllerProvider).isWishlisted('prod_01'), isFalse);
    });

    test('6. Transitions to empty state when both schemes and products are empty', () async {
      mockSchemeRepo.setCustomSchemes(<SchemeEntity>[]);
      mockProductRepo.setCustomProducts(<ProductEntity>[]);

      final OffersController controller =
          container.read(offersControllerProvider.notifier);
      await controller.loadOffersAndCatalog();

      final OffersState state = container.read(offersControllerProvider);
      expect(state.status, OffersStatus.empty);
      expect(state.schemes, isEmpty);
      expect(state.curatedProducts, isEmpty);
    });

    test('7. Transitions to error state on failure and recovers on retry', () async {
      mockSchemeRepo.setShouldThrow(true);

      final OffersController controller =
          container.read(offersControllerProvider.notifier);
      await controller.loadOffersAndCatalog();

      expect(container.read(offersControllerProvider).status, OffersStatus.error);

      // Now resolve error and retry
      mockSchemeRepo.setShouldThrow(false);
      await controller.retry();

      expect(container.read(offersControllerProvider).status, OffersStatus.loaded);
      expect(container.read(offersControllerProvider).schemes, isNotEmpty);
    });
  });
}
