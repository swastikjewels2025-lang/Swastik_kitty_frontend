import '../../domain/entities/passbook_entry_entity.dart';
import '../../domain/entities/passbook_summary_entity.dart';

/// Status states for Passbook.
enum PassbookStatus {
  initial,
  loading,
  loaded,
  refreshing,
  empty,
  error,
}

/// Visual presentation layout mode.
enum PassbookViewMode {
  table,
  card,
}

/// State container for customer's passbook ledger.
class PassbookState {
  const PassbookState({
    required this.status,
    this.viewMode = PassbookViewMode.table,
    this.entries = const <PassbookEntryEntity>[],
    this.summary,
    this.errorMessage,
  });

  const PassbookState.initial()
      : status = PassbookStatus.initial,
        viewMode = PassbookViewMode.table,
        entries = const <PassbookEntryEntity>[],
        summary = null,
        errorMessage = null;

  const PassbookState.loading({this.viewMode = PassbookViewMode.table})
      : status = PassbookStatus.loading,
        entries = const <PassbookEntryEntity>[],
        summary = null,
        errorMessage = null;

  const PassbookState.loaded({
    required this.entries,
    required this.summary,
    this.viewMode = PassbookViewMode.table,
  })  : status = PassbookStatus.loaded,
        errorMessage = null;

  const PassbookState.refreshing({
    required this.entries,
    required this.summary,
    this.viewMode = PassbookViewMode.table,
  })  : status = PassbookStatus.refreshing,
        errorMessage = null;

  const PassbookState.empty({this.viewMode = PassbookViewMode.table})
      : status = PassbookStatus.empty,
        entries = const <PassbookEntryEntity>[],
        summary = null,
        errorMessage = null;

  const PassbookState.error(
    this.errorMessage, {
    this.viewMode = PassbookViewMode.table,
  })  : status = PassbookStatus.error,
        entries = const <PassbookEntryEntity>[],
        summary = null;

  final PassbookStatus status;
  final PassbookViewMode viewMode;
  final List<PassbookEntryEntity> entries;
  final PassbookSummaryEntity? summary;
  final String? errorMessage;

  bool get isInitial => status == PassbookStatus.initial;
  bool get isLoading => status == PassbookStatus.loading;
  bool get isLoaded => status == PassbookStatus.loaded;
  bool get isRefreshing => status == PassbookStatus.refreshing;
  bool get isEmpty => status == PassbookStatus.empty;
  bool get isError => status == PassbookStatus.error;
  bool get isTableView => viewMode == PassbookViewMode.table;
  bool get isCardView => viewMode == PassbookViewMode.card;

  PassbookState copyWith({
    PassbookStatus? status,
    PassbookViewMode? viewMode,
    List<PassbookEntryEntity>? entries,
    PassbookSummaryEntity? summary,
    String? errorMessage,
  }) {
    return PassbookState(
      status: status ?? this.status,
      viewMode: viewMode ?? this.viewMode,
      entries: entries ?? this.entries,
      summary: summary ?? this.summary,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
