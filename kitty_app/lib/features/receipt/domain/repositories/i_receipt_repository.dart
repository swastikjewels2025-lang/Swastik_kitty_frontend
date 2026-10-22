import '../entities/receipt_entity.dart';

/// Repository contract for fetching and downloading payment receipts.
abstract class IReceiptRepository {
  /// Fetches receipt details by receipt ID.
  Future<ReceiptEntity> getReceipt(String receiptId);

  /// Fetches receipt details by transaction ID.
  Future<ReceiptEntity> getReceiptByTransactionId(String transactionId);

  /// Downloads receipt PDF bytes or returns a local file path.
  Future<List<int>> downloadReceiptPdf(String receiptId);
}
