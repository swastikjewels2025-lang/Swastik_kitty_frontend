import '../../../../core/enums/app_enums.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/repositories/i_kyc_repository.dart';
import '../dtos/kyc_dto.dart';
import '../mappers/kyc_mapper.dart';

/// Mock implementation of [IKycRepository].
class MockKycRepository implements IKycRepository {
  MockKycRepository({
    MockEngineConfig? engineConfig,
    KycStatusEnum initialStatus = KycStatusEnum.notSubmitted,
  })  : _engineConfig = engineConfig ?? MockEngineConfig.instance,
        _currentStatus = initialStatus;

  final MockEngineConfig _engineConfig;
  KycStatusEnum _currentStatus;
  String? _rejectionReason;
  KycResultEntity? _customResult;

  /// Helper to configure mock KYC status for testing.
  void setMockStatus(KycStatusEnum status, {String? rejectionReason}) {
    _currentStatus = status;
    _rejectionReason = rejectionReason;
  }

  /// Helper to set custom KYC result entity.
  void setCustomResult(KycResultEntity? result) {
    _customResult = result;
    if (result != null) {
      _currentStatus = result.status;
      _rejectionReason = result.rejectionReason;
    }
  }

  @override
  Future<KycResultEntity> submitKyc(KycSubmissionEntity submission) async {
    await _engineConfig.simulate();

    // 1. Validate 10 MB limit constraint from contract
    if (submission.fileSizeBytes != null &&
        submission.fileSizeBytes! > 10 * 1024 * 1024) {
      throw const ValidationException(
        'File size exceeds maximum permitted limit of 10 MB.',
        'FILE_TOO_LARGE',
        400,
      );
    }

    // 2. Validate Document Number Format
    final String cleanNumber = submission.documentNumber.replaceAll(' ', '');
    if (submission.documentType == DocTypeEnum.aadhaar) {
      if (cleanNumber.length != 12 || !RegExp(r'^\d{12}$').hasMatch(cleanNumber)) {
        throw const ValidationException(
          'Please enter a valid 12-digit Aadhaar number.',
          'INVALID_AADHAAR',
          400,
        );
      }
    } else if (submission.documentType == DocTypeEnum.pan) {
      if (cleanNumber.length != 10 ||
          !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(cleanNumber.toUpperCase())) {
        throw const ValidationException(
          'Please enter a valid 10-character PAN number.',
          'INVALID_PAN',
          400,
        );
      }
    }

    if (!submission.consentAgreed) {
      throw const ValidationException(
        'Please accept statutory compliance terms and consent.',
        'CONSENT_REQUIRED',
        400,
      );
    }

    final String masked = submission.documentType == DocTypeEnum.aadhaar
        ? (cleanNumber.length >= 4
            ? 'XXXX XXXX ${cleanNumber.substring(cleanNumber.length - 4)}'
            : 'XXXX XXXX 9012')
        : (cleanNumber.length >= 4
            ? 'XXXXXX${cleanNumber.substring(cleanNumber.length - 4)}'
            : 'XXXXXX5678');

    _currentStatus = KycStatusEnum.pending;

    final KycSubmitResponseDto dto = KycSubmitResponseDto(
      referenceId: 'KYC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      status: 'PENDING',
      documentType: submission.documentType.toJson(),
      documentNumberMasked: masked,
      documentUrl: 'https://res.cloudinary.com/swastik/image/upload/kyc/sample.jpg',
      submittedAt: DateTime.now().toUtc().toIso8601String(),
    );

    return KycMapper.toEntity(dto);
  }

  @override
  Future<KycResultEntity> getKycStatus() async {
    await _engineConfig.simulate();

    if (_customResult != null) {
      return _customResult!;
    }

    final KycSubmitResponseDto dto = KycSubmitResponseDto.fromJson(
      MockFixtures.kycSubmitSuccessJson['data'] as Map<String, dynamic>,
    );

    final KycResultEntity entity = KycMapper.toEntity(dto);
    return KycResultEntity(
      referenceId: entity.referenceId,
      status: _currentStatus,
      documentType: entity.documentType,
      documentNumberMasked: entity.documentNumberMasked,
      documentUrl: entity.documentUrl,
      submittedAt: entity.submittedAt,
      rejectionReason: _rejectionReason,
    );
  }
}
