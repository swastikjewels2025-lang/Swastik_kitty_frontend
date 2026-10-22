import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../dtos/product_dto.dart';
import '../mappers/home_mapper.dart';

/// Mock implementation of [IProductRepository].
class MockProductRepository implements IProductRepository {
  MockProductRepository({MockEngineConfig? engineConfig})
      : _engineConfig = engineConfig ?? MockEngineConfig.instance;

  final MockEngineConfig _engineConfig;
  bool _shouldThrow = false;
  List<ProductEntity>? _customProducts;

  // Scenario controls for testing
  void setShouldThrow(bool shouldThrow) => _shouldThrow = shouldThrow;
  void setCustomProducts(List<ProductEntity>? products) => _customProducts = products;

  @override
  Future<List<ProductEntity>> getCuratedProducts({String? category}) async {
    await _engineConfig.simulate();

    if (_shouldThrow) {
      throw const NetworkException('Failed to load curated products.');
    }

    final List<ProductEntity> products;
    if (_customProducts != null) {
      products = _customProducts!;
    } else {
      final List<dynamic> rawList =
          MockFixtures.curatedProductsJson['data']['products'] as List<dynamic>;

      products = rawList
          .map((dynamic json) =>
              HomeMapper.toProductEntity(ProductDto.fromJson(json as Map<String, dynamic>)))
          .toList();
    }

    if (category != null && category != 'All') {
      return products
          .where((ProductEntity p) => p.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    return products;
  }

  @override
  Future<List<String>> getCategories() async {
    await _engineConfig.simulate();

    if (_shouldThrow) {
      throw const NetworkException('Failed to load product categories.');
    }

    final List<dynamic> rawList =
        MockFixtures.curatedProductsJson['data']['categories'] as List<dynamic>;

    return rawList.map((dynamic e) => e.toString()).toList();
  }

  @override
  Future<ProductEntity> getProductById(String id) async {
    await _engineConfig.simulate();

    if (_shouldThrow) {
      throw const NetworkException('Failed to load product details.');
    }

    final List<ProductEntity> allProducts = await getCuratedProducts();
    return allProducts.firstWhere(
      (ProductEntity p) => p.id == id,
      orElse: () => throw const NotFoundException('Product not found.'),
    );
  }
}
