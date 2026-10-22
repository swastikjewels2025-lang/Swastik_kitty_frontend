import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/gold_rate_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_gold_rate_repository.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../dtos/gold_rate_dto.dart';
import '../mappers/home_mapper.dart';
import 'mock_product_repository.dart';

/// Remote implementation of [IGoldRateRepository] and [IProductRepository].
class HomeRepositoryImpl implements IGoldRateRepository, IProductRepository {
  HomeRepositoryImpl({required DioClient apiClient}) : _dio = apiClient;

  final DioClient _dio;

  @override
  Future<LiveGoldRateEntity> getLiveGoldRate() async {
    final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.ratesGold);
    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return HomeMapper.toGoldRateEntity(LiveGoldRateDto.fromJson(data));
  }

  final MockProductRepository _mockProductRepository = MockProductRepository();

  @override
  Future<List<ProductEntity>> getCuratedProducts({String? category}) {
    // The backend is tailored for Kitty Vault schemes and payments; jewellery showcase
    // catalog is intentionally mock-only. Delegate to MockProductRepository to avoid nonexistent /api/v1/products calls.
    return _mockProductRepository.getCuratedProducts(category: category);
  }

  @override
  Future<List<String>> getCategories() {
    return _mockProductRepository.getCategories();
  }

  @override
  Future<ProductEntity> getProductById(String id) {
    return _mockProductRepository.getProductById(id);
  }
}
