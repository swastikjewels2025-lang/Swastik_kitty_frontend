import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/passbook_entry_entity.dart';
import '../../domain/entities/passbook_summary_entity.dart';
import '../../domain/repositories/i_passbook_repository.dart';
import 'passbook_state.dart';

/// Riverpod provider for [PassbookController].
final NotifierProvider<PassbookController, PassbookState> passbookControllerProvider =
    NotifierProvider<PassbookController, PassbookState>(PassbookController.new);

/// Controller managing customer's 12-month installment passbook ledger,
/// view mode toggling, pull-to-refresh, and error recovery.
class PassbookController extends Notifier<PassbookState> {
  late IPassbookRepository _passbookRepository;

  @override
  PassbookState build() {
    _passbookRepository = ref.watch(passbookRepositoryProvider);

    // Initial load
    Future<void>.microtask(loadPassbook);

    return const PassbookState.loading();
  }

  /// Fetches passbook ledger records and summary metrics.
  Future<void> loadPassbook({bool refresh = false}) async {
    final PassbookViewMode currentMode = state.viewMode;
    final List<PassbookEntryEntity> cachedEntries = state.entries;
    final PassbookSummaryEntity? cachedSummary = state.summary;

    if (refresh && cachedEntries.isNotEmpty) {
      state = PassbookState.refreshing(
        entries: cachedEntries,
        summary: cachedSummary,
        viewMode: currentMode,
      );
    } else {
      state = PassbookState.loading(viewMode: currentMode);
    }

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _passbookRepository.getPassbookEntries(),
        _passbookRepository.getPassbookSummary(),
      ]);

      if (!ref.mounted) return;

      final List<PassbookEntryEntity> entries =
          results[0] as List<PassbookEntryEntity>;
      final PassbookSummaryEntity? summary =
          results[1] as PassbookSummaryEntity?;

      if (summary == null && entries.isEmpty) {
        state = PassbookState.empty(viewMode: currentMode);
      } else {
        state = PassbookState.loaded(
          entries: entries,
          summary: summary,
          viewMode: currentMode,
        );
      }
    } on AppException catch (e) {
      if (!ref.mounted) return;
      if (refresh && cachedEntries.isNotEmpty) {
        state = PassbookState(
          status: PassbookStatus.loaded,
          entries: cachedEntries,
          summary: cachedSummary,
          viewMode: currentMode,
          errorMessage: e.message,
        );
      } else {
        state = PassbookState.error(e.message, viewMode: currentMode);
      }
    } catch (_) {
      if (!ref.mounted) return;
      if (refresh && cachedEntries.isNotEmpty) {
        state = PassbookState(
          status: PassbookStatus.loaded,
          entries: cachedEntries,
          summary: cachedSummary,
          viewMode: currentMode,
          errorMessage: 'Failed to refresh. Showing cached passbook.',
        );
      } else {
        state = PassbookState.error(
          'Unable to load your passbook. Please check your connection and try again.',
          viewMode: currentMode,
        );
      }
    }
  }

  /// Retries fetching passbook data after failure.
  Future<void> retry() async {
    await loadPassbook();
  }

  /// Toggles between Table View and Card View layout.
  void setViewMode(PassbookViewMode mode) {
    if (state.viewMode == mode) return;
    state = state.copyWith(viewMode: mode);
  }
}
