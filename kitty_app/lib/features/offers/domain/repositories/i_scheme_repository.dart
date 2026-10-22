import '../entities/kitty_slot_entity.dart';
import '../entities/scheme_entity.dart';

/// Pure domain repository interface for gold savings scheme discovery.
abstract interface class ISchemeRepository {
  /// Retrieves list of active gold schemes.
  Future<List<SchemeEntity>> getActiveSchemes({int? durationFilter});

  /// Retrieves a specific scheme by unique ID.
  Future<SchemeEntity> getSchemeById(String id);

  /// Retrieves the numbered slot matrix for a scheme.
  Future<List<KittySlotEntity>> getAvailableNumbers(
    String schemeId, {
    int totalCapacity = 50,
  });

  /// Submits an enrollment request for a specific scheme and kitty number slot.
  Future<Map<String, dynamic>> enrollScheme({
    required String schemeId,
    required int monthlyAmount,
    required int slotNumber,
  });
}
