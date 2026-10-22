import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/kyc_entity.dart';
import '../dtos/kyc_dto.dart';

/// Mapper between KYC DTOs and Domain Entities.
abstract final class KycMapper {
  static KycResultEntity toEntity(KycSubmitResponseDto dto) {
    final DateTime? parsedSubmittedAt = dto.submittedAt != null
        ? DateTime.tryParse(dto.submittedAt!)?.toUtc()
        : null;

    return KycResultEntity(
      referenceId: dto.referenceId,
      status: KycStatusEnum.fromString(dto.status),
      documentType: DocTypeEnum.fromString(dto.documentType),
      documentNumberMasked: dto.documentNumberMasked,
      documentUrl: dto.documentUrl,
      submittedAt: parsedSubmittedAt,
      rejectionReason: dto.rejectionReason,
    );
  }
}
