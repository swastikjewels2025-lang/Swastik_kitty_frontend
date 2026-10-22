import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/kitty_slot_entity.dart';
import '../../domain/repositories/i_scheme_repository.dart';
import 'kitty_number_picker_state.dart';

/// Provider for managing Kitty Number slot matrix state.
final NotifierProvider<KittyNumberPickerController, KittyNumberPickerState>
    kittyNumberPickerControllerProvider =
    NotifierProvider<KittyNumberPickerController, KittyNumberPickerState>(
  KittyNumberPickerController.new,
);

/// Riverpod Notifier managing interactive number slot selection, search, and local locking.
class KittyNumberPickerController extends Notifier<KittyNumberPickerState> {
  late ISchemeRepository _repository;
  String? _schemeId;

  @override
  KittyNumberPickerState build() {
    _repository = ref.watch(schemeRepositoryProvider);
    return const KittyNumberPickerState();
  }

  /// Loads available numbers matrix for the specified scheme.
  Future<void> loadSlots(String schemeId, {bool refresh = false}) async {
    _schemeId = schemeId;
    if (!refresh &&
        state.status == KittyNumberPickerStatus.loaded &&
        state.slots.isNotEmpty) {
      return;
    }

    state = state.copyWith(status: KittyNumberPickerStatus.loading);

    try {
      final List<KittySlotEntity> slots =
          await _repository.getAvailableNumbers(schemeId);

      state = state.copyWith(
        status: KittyNumberPickerStatus.loaded,
        slots: slots,
        errorMessage: null,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        status: KittyNumberPickerStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: KittyNumberPickerStatus.error,
        errorMessage: 'Unable to load Kitty numbers. Please check connection.',
      );
    }
  }

  /// Attempts to select a slot. Returns true if successful, false if unavailable.
  bool selectSlot(KittySlotEntity slot) {
    if (slot.isBooked || slot.isLocked) {
      return false;
    }

    // If tapping already selected slot, toggle/unselect it
    if (state.selectedSlot?.number == slot.number) {
      state = state.copyWith(clearSelectedSlot: true, localLockExpiry: null);
      return true;
    }

    // Optimistic local lock for 15 minutes
    final DateTime lockExpiry = DateTime.now().add(const Duration(minutes: 15));

    state = state.copyWith(
      selectedSlot: slot,
      localLockExpiry: lockExpiry,
    );
    return true;
  }

  /// Clears the currently selected slot.
  void clearSelection() {
    state = state.copyWith(clearSelectedSlot: true, localLockExpiry: null);
  }

  /// Updates the real-time search query.
  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clears search filter.
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  /// Selects or searches for an auspicious lucky number (e.g. 7, 21, 51).
  bool selectLuckyNumber(int number) {
    try {
      final KittySlotEntity match =
          state.slots.firstWhere((KittySlotEntity s) => s.number == number);
      if (match.isAvailable) {
        return selectSlot(match);
      }
    } catch (_) {}
    return false;
  }

  /// Retries fetching slots upon failure.
  Future<void> retry() async {
    if (_schemeId != null) {
      await loadSlots(_schemeId!, refresh: true);
    }
  }
}
