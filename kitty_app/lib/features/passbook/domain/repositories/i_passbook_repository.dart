import '../entities/passbook_entry_entity.dart';
import '../entities/passbook_summary_entity.dart';

/// Pure domain repository interface for passbook installment ledger.
abstract interface class IPassbookRepository {
  /// Retrieves the 12-month passbook transaction matrix for the active scheme.
  Future<List<PassbookEntryEntity>> getPassbookEntries({String? membershipId});

  /// Retrieves the passbook summary metrics (chit token, tenure, total paid, accumulated gold).
  Future<PassbookSummaryEntity?> getPassbookSummary({String? membershipId});
}

