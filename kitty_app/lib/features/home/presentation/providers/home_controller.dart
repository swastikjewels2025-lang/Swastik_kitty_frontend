import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../dashboard/domain/entities/dashboard_summary_entity.dart';
import '../../../dashboard/domain/repositories/i_dashboard_repository.dart';
import '../../../offers/domain/entities/scheme_entity.dart';
import '../../../offers/domain/repositories/i_scheme_repository.dart';
import '../../domain/entities/gold_rate_entity.dart';
import '../../domain/entities/home_data_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_gold_rate_repository.dart';
import '../../domain/repositories/i_product_repository.dart';
import 'home_state.dart';

/// Riverpod provider for [HomeController].
final NotifierProvider<HomeController, HomeState> homeControllerProvider =
    NotifierProvider<HomeController, HomeState>(HomeController.new);

/// Controller managing data loading, category filtering, and refresh for the Home screen.
class HomeController extends Notifier<HomeState> {
  late IGoldRateRepository _goldRateRepository;
  late IProductRepository _productRepository;
  late ISchemeRepository _schemeRepository;
  late IDashboardRepository _dashboardRepository;

  DateTime? _lastLoadedTime;
  static const Duration _cacheTtl = Duration(seconds: 60);

  @override
  HomeState build() {
    _goldRateRepository = ref.watch(goldRateRepositoryProvider);
    _productRepository = ref.watch(productRepositoryProvider);
    _schemeRepository = ref.watch(schemeRepositoryProvider);
    _dashboardRepository = ref.watch(dashboardRepositoryProvider);

    // Trigger initial data load asynchronously after build
    Future<void>.microtask(loadHomeData);

    return const HomeState(status: HomeStatus.loading);
  }

  /// Fetches all required home screen datasets concurrently with 60s TTL caching.
  Future<void> loadHomeData({bool force = false}) async {
    if (!force &&
        state.status == HomeStatus.loaded &&
        state.data != null &&
        _lastLoadedTime != null &&
        DateTime.now().difference(_lastLoadedTime!) < _cacheTtl) {
      return;
    }

    state = state.copyWith(
      status: HomeStatus.loading,
      errorMessage: null,
    );

    try {
      final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
        _goldRateRepository.getLiveGoldRate(),
        _productRepository.getCuratedProducts(),
        _productRepository.getCategories(),
        _schemeRepository.getActiveSchemes(),
        _dashboardRepository.getMyDashboard(),
      ]);

      final LiveGoldRateEntity goldRate = results[0] as LiveGoldRateEntity;
      final List<ProductEntity> products = results[1] as List<ProductEntity>;
      final List<String> categories = results[2] as List<String>;
      final List<SchemeEntity> schemes = results[3] as List<SchemeEntity>;
      final DashboardSummaryEntity dashboard = results[4] as DashboardSummaryEntity;

      final HomeDataEntity homeData = HomeDataEntity(
        goldRate: goldRate,
        curatedProducts: products,
        categories: categories.isEmpty
            ? <String>['All', 'Rings', 'Earrings', 'Necklaces', 'Bangles', 'Bracelets', 'Pendants']
            : categories,
        schemes: schemes,
        activeKitty: dashboard.hasActiveScheme ? dashboard : null,
        selectedCategory: 'All',
      );

      _lastLoadedTime = DateTime.now();
      state = state.copyWith(
        status: HomeStatus.loaded,
        data: homeData,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.error,
        errorMessage:
            'Unable to load kitty and catalogue details. Please check your connection and try again.',
      );
    }
  }

  /// Refreshes home screen data without wiping existing content prematurely.
  Future<void> refresh() async {
    if (state.isLoading || state.isRefreshing) return;

    state = state.copyWith(status: HomeStatus.refreshing);

    try {
      final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
        _goldRateRepository.getLiveGoldRate(),
        _productRepository.getCuratedProducts(),
        _productRepository.getCategories(),
        _schemeRepository.getActiveSchemes(),
        _dashboardRepository.getMyDashboard(),
      ]);

      final LiveGoldRateEntity goldRate = results[0] as LiveGoldRateEntity;
      final List<ProductEntity> products = results[1] as List<ProductEntity>;
      final List<String> categories = results[2] as List<String>;
      final List<SchemeEntity> schemes = results[3] as List<SchemeEntity>;
      final DashboardSummaryEntity dashboard = results[4] as DashboardSummaryEntity;

      final String currentCategory = state.data?.selectedCategory ?? 'All';

      final HomeDataEntity homeData = HomeDataEntity(
        goldRate: goldRate,
        curatedProducts: products,
        categories: categories.isEmpty
            ? <String>['All', 'Rings', 'Earrings', 'Necklaces', 'Bangles', 'Bracelets', 'Pendants']
            : categories,
        schemes: schemes,
        activeKitty: dashboard.hasActiveScheme ? dashboard : null,
        selectedCategory: currentCategory,
      );

      _lastLoadedTime = DateTime.now();
      state = state.copyWith(
        status: HomeStatus.loaded,
        data: homeData,
        errorMessage: null,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        status: HomeStatus.loaded,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.loaded,
        errorMessage: 'Failed to refresh. Showing cached data.',
      );
    }
  }

  /// Selects a category filter for the curated jewellery grid.
  void selectCategory(String category) {
    if (state.data == null) return;
    state = state.copyWith(
      data: state.data!.copyWith(selectedCategory: category),
    );
  }
}
