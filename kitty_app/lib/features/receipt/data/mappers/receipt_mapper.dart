import '../../domain/entities/receipt_entity.dart';
import '../models/receipt_dto.dart';

/// Mapper between ReceiptDto and ReceiptEntity.
class ReceiptMapper {
  static ReceiptEntity toEntity(ReceiptDto dto) {
    return ReceiptEntity(
      receiptId: dto.receiptId,
      transactionId: dto.transactionId,
      paymentOrderId: dto.paymentOrderId,
      membershipId: dto.membershipId,
      customerName: dto.customerName,
      customerPhone: dto.customerPhone,
      schemeName: dto.schemeName,
      installmentNumber: dto.installmentNumber,
      totalInstallments: dto.totalInstallments,
      amount: dto.amount,
      goldRateAtPayment: dto.goldRateAtPayment,
      goldWeightCreditedGrams: dto.goldWeightCreditedGrams,
      paymentMethod: dto.paymentMethod,
      paymentStatus: dto.paymentStatus,
      paidAt: DateTime.tryParse(dto.paidAt)?.toUtc() ?? DateTime.now().toUtc(),
      pdfUrl: dto.pdfUrl,
    );
  }

  static ReceiptDto toDto(ReceiptEntity entity) {
    return ReceiptDto(
      receiptId: entity.receiptId,
      transactionId: entity.transactionId,
      paymentOrderId: entity.paymentOrderId,
      membershipId: entity.membershipId,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      schemeName: entity.schemeName,
      installmentNumber: entity.installmentNumber,
      totalInstallments: entity.totalInstallments,
      amount: entity.amount,
      goldRateAtPayment: entity.goldRateAtPayment,
      goldWeightCreditedGrams: entity.goldWeightCreditedGrams,
      paymentMethod: entity.paymentMethod,
      paymentStatus: entity.paymentStatus,
      paidAt: entity.paidAt.toIso8601String(),
      pdfUrl: entity.pdfUrl,
    );
  }
}
