import '../../domain/entities/kitty_slot_entity.dart';

/// Loading status for the Kitty Number matrix.
enum KittyNumberPickerStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Immutable state representing the interactive Kitty Number slot selection matrix.
class KittyNumberPickerState {
  const KittyNumberPickerState({
    this.status = KittyNumberPickerStatus.initial,
    this.slots = const <KittySlotEntity>[],
    this.selectedSlot,
    this.searchQuery = '',
    this.errorMessage,
    this.localLockExpiry,
  });

  final KittyNumberPickerStatus status;
  final List<KittySlotEntity> slots;
  final KittySlotEntity? selectedSlot;
  final String searchQuery;
  final String? errorMessage;
  final DateTime? localLockExpiry;

  /// Returns slots matching the patron's search query (number or token).
  List<KittySlotEntity> get filteredSlots {
    if (searchQuery.trim().isEmpty) {
      return slots;
    }
    final String query = searchQuery.trim().toLowerCase();
    return slots.where((KittySlotEntity slot) {
      final String numStr = slot.number.toString();
      final String tokenStr = slot.tokenString.toLowerCase();
      return numStr == query ||
          numStr.contains(query) ||
          tokenStr.contains(query);
    }).toList();
  }

  bool get hasSelection => selectedSlot != null;

  int get availableCount => slots.where((s) => s.isAvailable).length;
  int get bookedCount => slots.where((s) => s.isBooked).length;
  int get lockedCount => slots.where((s) => s.isLocked).length;

  KittyNumberPickerState copyWith({
    KittyNumberPickerStatus? status,
    List<KittySlotEntity>? slots,
    KittySlotEntity? selectedSlot,
    bool clearSelectedSlot = false,
    String? searchQuery,
    String? errorMessage,
    DateTime? localLockExpiry,
  }) {
    return KittyNumberPickerState(
      status: status ?? this.status,
      slots: slots ?? this.slots,
      selectedSlot: clearSelectedSlot ? null : (selectedSlot ?? this.selectedSlot),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      localLockExpiry: localLockExpiry ?? this.localLockExpiry,
    );
  }
}
