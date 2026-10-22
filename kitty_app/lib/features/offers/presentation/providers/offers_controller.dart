import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/domain/repositories/i_product_repository.dart';
import '../../domain/entities/scheme_entity.dart';
import '../../domain/repositories/i_scheme_repository.dart';
import 'offers_state.dart';

/// Global provider for [OffersController] state management.
final NotifierProvider<OffersController, OffersState> offersControllerProvider =
    NotifierProvider<OffersController, OffersState>(OffersController.new);

/// Riverpod Notifier managing state for the Kitty Offers & Product Catalog module.
class OffersController extends Notifier<OffersState> {
  late final ISchemeRepository _schemeRepository;
  late final IProductRepository _productRepository;

  DateTime? _lastLoadedTime;
  static const Duration _cacheTtl = Duration(seconds: 60);

  @override
  OffersState build() {
    _schemeRepository = ref.watch(schemeRepositoryProvider);
    _productRepository = ref.watch(productRepositoryProvider);

    // Trigger initial fetch
    Future<void>.microtask(loadOffersAndCatalog);

    return const OffersState(status: OffersStatus.loading);
  }

  /// Loads both gold schemes and curated jewelry products from repository layer with 60s caching.
  Future<void> loadOffersAndCatalog({bool refresh = false}) async {
    if (!refresh &&
        state.status == OffersStatus.loaded &&
        _lastLoadedTime != null &&
        DateTime.now().difference(_lastLoadedTime!) < _cacheTtl) {
      return;
    }

    if (!refresh) {
      state = state.copyWith(status: OffersStatus.loading);
    }

    try {
      final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
        _schemeRepository.getActiveSchemes(),
        _productRepository.getCuratedProducts(),
        _productRepository.getCategories(),
      ]);

      final List<SchemeEntity> schemes = results[0] as List<SchemeEntity>;
      final List<ProductEntity> products = results[1] as List<ProductEntity>;
      final List<String> rawCategories = results[2] as List<String>;

      // Ensure 'All' category chip is always the primary selector
      final List<String> categories = <String>[
        'All',
        ...rawCategories.where((String c) => c.toLowerCase() != 'all'),
      ];

      if (schemes.isEmpty && products.isEmpty) {
        state = state.copyWith(
          status: OffersStatus.empty,
          schemes: <SchemeEntity>[],
          curatedProducts: <ProductEntity>[],
          categories: categories,
        );
        return;
      }

      _lastLoadedTime = DateTime.now();
      state = state.copyWith(
        status: OffersStatus.loaded,
        schemes: schemes,
        curatedProducts: products,
        categories: categories,
        errorMessage: () => null,
      );
    } on AppException catch (e, stack) {
      debugPrint('[OffersController AppException] $e\n$stack');
      if (refresh && (state.schemes.isNotEmpty || state.curatedProducts.isNotEmpty)) {
        state = state.copyWith(
          status: OffersStatus.loaded,
          errorMessage: () => e.message,
        );
      } else {
        state = state.copyWith(
          status: OffersStatus.error,
          errorMessage: () => e.message,
        );
      }
    } catch (e, stack) {
      debugPrint('[OffersController Generic Error] $e\n$stack');
      if (refresh && (state.schemes.isNotEmpty || state.curatedProducts.isNotEmpty)) {
        state = state.copyWith(
          status: OffersStatus.loaded,
          errorMessage: () => 'Failed to refresh. Showing cached catalog.',
        );
      } else {
        state = state.copyWith(
          status: OffersStatus.error,
          errorMessage: () => 'Unable to load offers and jewellery catalog ($e).',
        );
      }
    }
  }

  /// Changes the active primary section between Schemes and Catalog.
  void setSection(OffersViewSection section) {
    state = state.copyWith(activeSection: section);
  }

  /// Filters schemes by duration in months (12, 18, 6, or null for All).
  void setDurationFilter(int? duration) {
    state = state.copyWith(selectedDuration: () => duration);
  }

  /// Filters curated products by category name.
  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Toggles saved state of a product in the user's local wishlist.
  void toggleWishlist(String productId) {
    final Set<String> updated = Set<String>.from(state.wishlistedProductIds);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    state = state.copyWith(wishlistedProductIds: updated);
  }

  /// Retries fetching after an error occurred.
  Future<void> retry() => loadOffersAndCatalog(refresh: true);
}
