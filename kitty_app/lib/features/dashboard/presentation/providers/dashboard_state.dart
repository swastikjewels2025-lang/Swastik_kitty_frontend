import '../../domain/entities/dashboard_summary_entity.dart';

/// Status states for Dashboard.
enum DashboardStatus {
  initial,
  loading,
  loaded,
  refreshing,
  empty,
  error,
}

/// State container for Kitty Dashboard.
class DashboardState {
  const DashboardState({
    required this.status,
    this.data,
    this.schemes = const <DashboardSummaryEntity>[],
    this.selectedSchemeIndex = 0,
    this.errorMessage,
  });

  const DashboardState.initial()
      : status = DashboardStatus.initial,
        data = null,
        schemes = const <DashboardSummaryEntity>[],
        selectedSchemeIndex = 0,
        errorMessage = null;

  const DashboardState.loading()
      : status = DashboardStatus.loading,
        data = null,
        schemes = const <DashboardSummaryEntity>[],
        selectedSchemeIndex = 0,
        errorMessage = null;

  const DashboardState.loaded(
    this.data, {
    this.schemes = const <DashboardSummaryEntity>[],
    this.selectedSchemeIndex = 0,
  })  : status = DashboardStatus.loaded,
        errorMessage = null;

  const DashboardState.refreshing(
    this.data, {
    this.schemes = const <DashboardSummaryEntity>[],
    this.selectedSchemeIndex = 0,
  })  : status = DashboardStatus.refreshing,
        errorMessage = null;

  const DashboardState.empty()
      : status = DashboardStatus.empty,
        data = null,
        schemes = const <DashboardSummaryEntity>[],
        selectedSchemeIndex = 0,
        errorMessage = null;

  const DashboardState.error(String message)
      : status = DashboardStatus.error,
        data = null,
        schemes = const <DashboardSummaryEntity>[],
        selectedSchemeIndex = 0,
        errorMessage = message;

  final DashboardStatus status;
  final DashboardSummaryEntity? data;
  final List<DashboardSummaryEntity> schemes;
  final int selectedSchemeIndex;
  final String? errorMessage;

  DashboardSummaryEntity? get selectedScheme =>
      schemes.isNotEmpty && selectedSchemeIndex < schemes.length
          ? schemes[selectedSchemeIndex]
          : data;

  bool get hasMultipleSchemes => schemes.length > 1;

  bool get isInitial => status == DashboardStatus.initial;
  bool get isLoading => status == DashboardStatus.loading;
  bool get isLoaded => status == DashboardStatus.loaded;
  bool get isRefreshing => status == DashboardStatus.refreshing;
  bool get isEmpty => status == DashboardStatus.empty;
  bool get isError => status == DashboardStatus.error;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSummaryEntity? data,
    List<DashboardSummaryEntity>? schemes,
    int? selectedSchemeIndex,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      schemes: schemes ?? this.schemes,
      selectedSchemeIndex: selectedSchemeIndex ?? this.selectedSchemeIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
