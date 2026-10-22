import '../../domain/entities/home_data_entity.dart';

/// State representation for Home screen state machine.
enum HomeStatus {
  initial,
  loading,
  loaded,
  refreshing,
  error,
  empty,
}

/// Immutable state for the Home screen.
class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.data,
    this.errorMessage,
  });

  final HomeStatus status;
  final HomeDataEntity? data;
  final String? errorMessage;

  bool get isLoading => status == HomeStatus.loading;
  bool get isLoaded => status == HomeStatus.loaded;
  bool get isRefreshing => status == HomeStatus.refreshing;
  bool get isError => status == HomeStatus.error;
  bool get isEmpty => status == HomeStatus.empty;

  HomeState copyWith({
    HomeStatus? status,
    HomeDataEntity? data,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          data == other.data &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, data, errorMessage);
}
