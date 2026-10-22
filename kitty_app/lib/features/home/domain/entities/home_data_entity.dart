import '../../../auth/domain/entities/user_entity.dart';
import '../../../dashboard/domain/entities/dashboard_summary_entity.dart';
import '../../../offers/domain/entities/scheme_entity.dart';
import 'gold_rate_entity.dart';
import 'product_entity.dart';

/// Aggregated pure domain entity holding all components for the Home screen.
class HomeDataEntity {
  const HomeDataEntity({
    required this.goldRate,
    required this.curatedProducts,
    required this.categories,
    required this.schemes,
    this.user,
    this.activeKitty,
    this.selectedCategory = 'All',
  });

  /// 24K and 22K live gold rates.
  final LiveGoldRateEntity? goldRate;

  /// Curated luxury jewellery catalog for 2-column showcase.
  final List<ProductEntity> curatedProducts;

  /// Available jewellery categories.
  final List<String> categories;

  /// Featured kitty schemes / promotional privileges.
  final List<SchemeEntity> schemes;

  /// Authenticated user profile for greeting.
  final UserEntity? user;

  /// Active kitty savings plan summary (null if user has no active scheme).
  final DashboardSummaryEntity? activeKitty;

  /// Currently selected category filter.
  final String selectedCategory;

  /// Returns filtered products based on [selectedCategory].
  List<ProductEntity> get filteredProducts {
    if (selectedCategory == 'All' || selectedCategory.isEmpty) {
      return curatedProducts;
    }
    return curatedProducts
        .where((ProductEntity p) =>
            p.category.toLowerCase() == selectedCategory.toLowerCase())
        .toList();
  }

  HomeDataEntity copyWith({
    LiveGoldRateEntity? goldRate,
    List<ProductEntity>? curatedProducts,
    List<String>? categories,
    List<SchemeEntity>? schemes,
    UserEntity? user,
    DashboardSummaryEntity? activeKitty,
    String? selectedCategory,
  }) {
    return HomeDataEntity(
      goldRate: goldRate ?? this.goldRate,
      curatedProducts: curatedProducts ?? this.curatedProducts,
      categories: categories ?? this.categories,
      schemes: schemes ?? this.schemes,
      user: user ?? this.user,
      activeKitty: activeKitty ?? this.activeKitty,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
