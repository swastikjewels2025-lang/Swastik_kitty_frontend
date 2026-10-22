import 'dart:convert';
import '../../../../core/mock/mock_fixtures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/receipt_entity.dart';
import '../../domain/repositories/i_receipt_repository.dart';
import '../mappers/receipt_mapper.dart';
import '../models/receipt_dto.dart';

/// Implementation of [IReceiptRepository].
///
/// NOTE: The backend generates receipts server-side (via pdfkit) and attaches
/// Cloudinary URLs directly to payments and passbook transactions.
/// There are no separate `/api/v1/receipts/*` REST endpoints on the backend.
/// To avoid HTTP 404 errors, this repository resolves receipt data locally
/// or delegates to local fixtures.
class ReceiptRepositoryImpl implements IReceiptRepository {
  ReceiptRepositoryImpl({this.apiClient});

  final DioClient? apiClient;

  @override
  Future<ReceiptEntity> getReceipt(String receiptId) async {
    final data = MockFixtures.digitalReceiptJson['data'] as Map<String, dynamic>? ?? {};
    return ReceiptMapper.toEntity(ReceiptDto.fromJson(data));
  }

  @override
  Future<ReceiptEntity> getReceiptByTransactionId(String transactionId) async {
    final data = Map<String, dynamic>.from(
      MockFixtures.digitalReceiptJson['data'] as Map<String, dynamic>? ?? {},
    );
    data['transactionId'] = transactionId;
    return ReceiptMapper.toEntity(ReceiptDto.fromJson(data));
  }

  @override
  Future<List<int>> downloadReceiptPdf(String receiptId) async {
    return utf8.encode('%PDF-1.4 Mock Receipt for $receiptId\n%%EOF');
  }
}
