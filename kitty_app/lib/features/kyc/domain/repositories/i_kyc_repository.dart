import '../entities/kyc_entity.dart';

/// Pure domain repository interface for KYC compliance operations.
abstract interface class IKycRepository {
  /// Submits statutory KYC documents.
  Future<KycResultEntity> submitKyc(KycSubmissionEntity submission);

  /// Retrieves current KYC status.
  Future<KycResultEntity> getKycStatus();
}
