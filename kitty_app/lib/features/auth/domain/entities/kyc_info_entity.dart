import '../../../../core/enums/app_enums.dart';

/// Domain entity representing user statutory KYC compliance details.
class KycInfoEntity {
  const KycInfoEntity({
    required this.isVerified,
    required this.status,
    this.documentType,
    this.documentNumberMasked,
    this.documentUrl,
    this.rejectionReason,
  });

  final bool isVerified;
  final KycStatusEnum status;
  final DocTypeEnum? documentType;
  final String? documentNumberMasked;
  final String? documentUrl;
  final String? rejectionReason;
}
