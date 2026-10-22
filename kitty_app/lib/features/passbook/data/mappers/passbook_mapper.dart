import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/passbook_entry_entity.dart';
import '../dtos/passbook_dto.dart';

/// Mapper between Passbook DTO and Domain Entity.
abstract final class PassbookMapper {
  static PassbookEntryEntity toEntity(PassbookEntryDto dto) {
    final DateTime? parsedPaidAt = dto.paidAt != null
        ? DateTime.tryParse(dto.paidAt!)?.toUtc()
        : null;

    final DateTime? parsedDueDate = dto.dueDate != null
        ? DateTime.tryParse(dto.dueDate!)?.toUtc()
        : null;

    return PassbookEntryEntity(
      month: dto.month,
      label: dto.label,
      amount: dto.amount, // Whole integer rupees preserved
      status: InstallmentStatusEnum.fromString(dto.status),
      paidAt: parsedPaidAt,
      dueDate: parsedDueDate,
      paymentMethod: dto.paymentMethod != null
          ? PaymentMethodEnum.fromString(dto.paymentMethod)
          : null,
      transactionId: dto.transactionId,
      goldGrams: dto.goldGrams, // 3-decimal gold precision preserved
      receiptUrl: dto.receiptUrl,
      bonusNote: dto.bonusNote,
      monthName: dto.monthName,
    );
  }
}
