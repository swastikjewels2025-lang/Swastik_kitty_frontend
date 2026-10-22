import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../home/domain/entities/gold_rate_entity.dart';
import '../../../home/domain/repositories/i_gold_rate_repository.dart';
import 'live_rate_state.dart';

/// Riverpod provider for [LiveRateController].
final NotifierProvider<LiveRateController, LiveRateState> liveRateControllerProvider =
    NotifierProvider<LiveRateController, LiveRateState>(LiveRateController.new);

/// Controller managing data loading, manual pull-to-refresh, and caching for the Live Rates screen.
class LiveRateController extends Notifier<LiveRateState> {
  late IGoldRateRepository _goldRateRepository;
  DateTime? _lastLoadedTime;
  static const Duration _cacheTtl = Duration(seconds: 60);

  @override
  LiveRateState build() {
    _goldRateRepository = ref.watch(goldRateRepositoryProvider);

    // Initial load
    Future<void>.microtask(loadRates);

    return const LiveRateState(status: LiveRateStatus.loading);
  }

  /// Fetches live gold and silver rates with 60s TTL caching.
  Future<void> loadRates({bool force = false}) async {
    if (!force &&
        state.status == LiveRateStatus.loaded &&
        state.data != null &&
        _lastLoadedTime != null &&
        DateTime.now().difference(_lastLoadedTime!) < _cacheTtl) {
      return;
    }

    state = state.copyWith(
      status: LiveRateStatus.loading,
      errorMessage: null,
    );

    try {
      final LiveGoldRateEntity rates = await _goldRateRepository.getLiveGoldRate();
      _lastLoadedTime = DateTime.now();
      state = state.copyWith(
        status: LiveRateStatus.loaded,
        data: rates,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        status: LiveRateStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: LiveRateStatus.error,
        errorMessage:
            'Unable to fetch live bullion market rates. Please check your internet connection.',
      );
    }
  }

  /// Manual pull-to-refresh without clearing existing cached rates prematurely.
  Future<void> refresh() async {
    if (state.isLoading || state.isRefreshing) return;

    state = state.copyWith(status: LiveRateStatus.refreshing);

    try {
      final LiveGoldRateEntity rates = await _goldRateRepository.getLiveGoldRate();
      _lastLoadedTime = DateTime.now();
      state = state.copyWith(
        status: LiveRateStatus.loaded,
        data: rates,
        errorMessage: null,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        status: LiveRateStatus.loaded,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: LiveRateStatus.loaded,
        errorMessage: 'Failed to refresh rates. Showing cached market rates.',
      );
    }
  }
}
