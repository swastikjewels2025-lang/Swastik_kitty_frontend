import '../../../home/domain/entities/gold_rate_entity.dart';

/// Semantic loading status for Live Rates screen.
enum LiveRateStatus {
  initial,
  loading,
  loaded,
  refreshing,
  error,
}

/// State container for the dedicated Live Rates screen.
class LiveRateState {
  const LiveRateState({
    this.status = LiveRateStatus.initial,
    this.data,
    this.errorMessage,
  });

  final LiveRateStatus status;
  final LiveGoldRateEntity? data;
  final String? errorMessage;

  bool get isLoading => status == LiveRateStatus.loading;
  bool get isLoaded => status == LiveRateStatus.loaded;
  bool get isRefreshing => status == LiveRateStatus.refreshing;
  bool get isError => status == LiveRateStatus.error;

  LiveRateState copyWith({
    LiveRateStatus? status,
    LiveGoldRateEntity? data,
    String? errorMessage,
  }) {
    return LiveRateState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
