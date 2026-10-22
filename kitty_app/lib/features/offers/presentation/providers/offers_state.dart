import '../../domain/entities/scheme_entity.dart';
import '../../../home/domain/entities/product_entity.dart';

/// Presentation state status for the Offers & Product Catalog screen.
enum OffersStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// Primary section toggle between Kitty Savings Schemes and Curated Jewellery Catalog.
enum OffersViewSection {
  schemes,
  catalog,
}

/// Immutable state holder for the Kitty Offers and Product Catalog module.
class OffersState {
  const OffersState({
    this.status = OffersStatus.initial,
    this.activeSection = OffersViewSection.schemes,
    this.schemes = const <SchemeEntity>[],
    this.selectedDuration,
    this.curatedProducts = const <ProductEntity>[],
    this.categories = const <String>['All'],
    this.selectedCategory = 'All',
    this.wishlistedProductIds = const <String>{},
    this.errorMessage,
  });

  final OffersStatus status;
  final OffersViewSection activeSection;
  final List<SchemeEntity> schemes;
  final int? selectedDuration;
  final List<ProductEntity> curatedProducts;
  final List<String> categories;
  final String selectedCategory;
  final Set<String> wishlistedProductIds;
  final String? errorMessage;

  /// Returns schemes filtered by the active duration tab, if any.
  List<SchemeEntity> get filteredSchemes {
    if (selectedDuration == null) return schemes;
    return schemes
        .where((SchemeEntity s) => s.durationMonths == selectedDuration)
        .toList();
  }

  /// Returns curated products filtered by the active category chip.
  List<ProductEntity> get filteredProducts {
    if (selectedCategory == 'All') return curatedProducts;
    return curatedProducts
        .where((ProductEntity p) =>
            p.category.toLowerCase() == selectedCategory.toLowerCase())
        .toList();
  }

  /// Checks if a product is saved in wishlist.
  bool isWishlisted(String productId) => wishlistedProductIds.contains(productId);

  OffersState copyWith({
    OffersStatus? status,
    OffersViewSection? activeSection,
    List<SchemeEntity>? schemes,
    int? Function()? selectedDuration,
    List<ProductEntity>? curatedProducts,
    List<String>? categories,
    String? selectedCategory,
    Set<String>? wishlistedProductIds,
    String? Function()? errorMessage,
  }) {
    return OffersState(
      status: status ?? this.status,
      activeSection: activeSection ?? this.activeSection,
      schemes: schemes ?? this.schemes,
      selectedDuration: selectedDuration != null
          ? selectedDuration()
          : this.selectedDuration,
      curatedProducts: curatedProducts ?? this.curatedProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      wishlistedProductIds: wishlistedProductIds ?? this.wishlistedProductIds,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
