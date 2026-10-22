import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/repositories/i_dashboard_repository.dart';
import 'dashboard_state.dart';

/// Riverpod provider for [DashboardController].
final NotifierProvider<DashboardController, DashboardState> dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(DashboardController.new);

/// Controller managing active scheme dashboard metrics, loading, refresh, and multi-scheme switching.
class DashboardController extends Notifier<DashboardState> {
  late IDashboardRepository _dashboardRepository;
  DateTime? _lastLoadedTime;
  static const Duration _cacheTtl = Duration(seconds: 60);

  @override
  DashboardState build() {
    _dashboardRepository = ref.watch(dashboardRepositoryProvider);

    // Trigger initial data load
    Future<void>.microtask(loadDashboard);

    return const DashboardState.loading();
  }

  /// Fetches active kitty dashboard summary from repository (supporting multiple schemes).
  Future<void> loadDashboard({bool refresh = false}) async {
    // Return cached data if still valid within TTL and not a force refresh
    if (!refresh &&
        state.status == DashboardStatus.loaded &&
        state.data != null &&
        _lastLoadedTime != null &&
        DateTime.now().difference(_lastLoadedTime!) < _cacheTtl) {
      return;
    }

    final DashboardSummaryEntity? cachedData = state.data;
    final List<DashboardSummaryEntity> cachedSchemes = state.schemes;

    if (refresh && cachedData != null) {
      state = DashboardState.refreshing(
        cachedData,
        schemes: cachedSchemes,
        selectedSchemeIndex: state.selectedSchemeIndex,
      );
    } else {
      state = const DashboardState.loading();
    }

    try {
      final List<DashboardSummaryEntity> schemes = await _dashboardRepository.getMySchemes();
      _lastLoadedTime = DateTime.now();

      final List<DashboardSummaryEntity> activeSchemes =
          schemes.where((DashboardSummaryEntity s) => s.hasActiveScheme).toList();

      if (activeSchemes.isEmpty) {
        state = const DashboardState.empty();
      } else {
        final int targetIndex = state.selectedSchemeIndex.clamp(0, activeSchemes.length - 1);
        state = DashboardState.loaded(
          activeSchemes[targetIndex],
          schemes: activeSchemes,
          selectedSchemeIndex: targetIndex,
        );
      }
    } on AppException catch (e) {
      if (refresh && cachedData != null) {
        state = DashboardState(
          status: DashboardStatus.loaded,
          data: cachedData,
          schemes: cachedSchemes,
          selectedSchemeIndex: state.selectedSchemeIndex,
          errorMessage: e.message,
        );
      } else {
        state = DashboardState.error(e.message);
      }
    } catch (_) {
      if (refresh && cachedData != null) {
        state = DashboardState(
          status: DashboardStatus.loaded,
          data: cachedData,
          schemes: cachedSchemes,
          selectedSchemeIndex: state.selectedSchemeIndex,
          errorMessage: 'Failed to refresh. Showing cached data.',
        );
      } else {
        state = const DashboardState.error(
          'Unable to load your kitty details. Please check your connection and try again.',
        );
      }
    }
  }

  /// Selects an active scheme from the user's multi-scheme portfolio.
  void selectScheme(int index) {
    if (index < 0 || index >= state.schemes.length) return;
    if (index == state.selectedSchemeIndex) return;
    state = state.copyWith(
      selectedSchemeIndex: index,
      data: state.schemes[index],
    );
  }

  /// Selects a scheme matching a specific chitToken (e.g. #SW-018).
  void selectSchemeByChitToken(String chitToken) {
    final int idx = state.schemes.indexWhere((s) => s.chitToken == chitToken);
    if (idx != -1) {
      selectScheme(idx);
    }
  }

  /// Retries loading dashboard data.
  Future<void> retry() async {
    await loadDashboard(refresh: true);
  }
}
