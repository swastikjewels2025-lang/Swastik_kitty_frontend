/// Visual and booking status of a specific Kitty Number slot.
enum KittySlotStatus {
  available,
  selected,
  booked,
  locked, // Temporarily held during checkout reservation
}

/// Pure domain entity representing a single numbered slot in a Kitty scheme.
class KittySlotEntity {
  const KittySlotEntity({
    required this.number,
    required this.status,
    required this.tokenString,
    this.lockedUntil,
  });

  final int number;
  final KittySlotStatus status;
  final String tokenString;
  final DateTime? lockedUntil;

  bool get isAvailable => status == KittySlotStatus.available;
  bool get isBooked => status == KittySlotStatus.booked;
  bool get isLocked => status == KittySlotStatus.locked;
  bool get isSelected => status == KittySlotStatus.selected;

  KittySlotEntity copyWith({
    int? number,
    KittySlotStatus? status,
    String? tokenString,
    DateTime? lockedUntil,
  }) {
    return KittySlotEntity(
      number: number ?? this.number,
      status: status ?? this.status,
      tokenString: tokenString ?? this.tokenString,
      lockedUntil: lockedUntil ?? this.lockedUntil,
    );
  }
}
