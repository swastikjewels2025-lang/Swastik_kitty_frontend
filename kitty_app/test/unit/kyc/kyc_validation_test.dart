import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/utils/input_validators.dart';
import 'package:kitty_app/features/kyc/data/dtos/kyc_dto.dart';
import 'package:kitty_app/features/kyc/data/mappers/kyc_mapper.dart';
import 'package:kitty_app/features/kyc/data/repositories/mock_kyc_repository.dart';
import 'package:kitty_app/features/kyc/domain/entities/kyc_entity.dart';

void main() {
  group('KYC Validation & Domain Suite', () {
    test('1. Aadhaar input validation', () {
      expect(InputValidators.validateAadhaar('123456789012'), isNull);
      expect(InputValidators.validateAadhaar('1234 5678 9012'), isNull);
      expect(InputValidators.validateAadhaar('12345678901'), isNotNull);
      expect(InputValidators.validateAadhaar('1234567890123'), isNotNull);
      expect(InputValidators.validateAadhaar(''), isNotNull);
      expect(InputValidators.validateAadhaar('abcdefghijkl'), isNotNull);
    });

    test('2. PAN input validation', () {
      expect(InputValidators.validatePan('ABCDE1234F'), isNull);
      expect(InputValidators.validatePan('abcde1234f'), isNull); // handles lowercase
      expect(InputValidators.validatePan('ABCDE1234'), isNotNull); // 9 chars
      expect(InputValidators.validatePan('ABCDE12345'), isNotNull); // last char is digit
      expect(InputValidators.validatePan('12345ABCDE'), isNotNull);
      expect(InputValidators.validatePan(''), isNotNull);
    });

    test('3. SelectedKycFile properties and size formatting', () {
      const SelectedKycFile imgFile = SelectedKycFile(
        name: 'aadhaar_front.jpg',
        path: '/tmp/aadhaar_front.jpg',
        sizeBytes: 1572864, // 1.5 MB
        mimeType: 'image/jpeg',
      );
      expect(imgFile.isImage, isTrue);
      expect(imgFile.isPdf, isFalse);
      expect(imgFile.formattedSize, '1.5 MB');

      const SelectedKycFile pdfFile = SelectedKycFile(
        name: 'pan_card.pdf',
        path: '/tmp/pan_card.pdf',
        sizeBytes: 512000, // 500 KB
        mimeType: 'application/pdf',
      );
      expect(pdfFile.isImage, isFalse);
      expect(pdfFile.isPdf, isTrue);
      expect(pdfFile.formattedSize, '500.0 KB');
    });

    test('4. KycMapper parses DTO and handles unknown status safely', () {
      const KycSubmitResponseDto dto = KycSubmitResponseDto(
        referenceId: 'KYC-999999',
        status: 'PENDING',
        documentType: 'AADHAAR',
        documentNumberMasked: 'XXXX XXXX 1234',
        documentUrl: 'https://cdn.swastik.com/doc.jpg',
        submittedAt: '2026-09-16T10:00:00.000Z',
        rejectionReason: null,
      );

      final KycResultEntity entity = KycMapper.toEntity(dto);
      expect(entity.referenceId, 'KYC-999999');
      expect(entity.status, KycStatusEnum.pending);
      expect(entity.documentType, DocTypeEnum.aadhaar);
      expect(entity.documentNumberMasked, 'XXXX XXXX 1234');
      expect(entity.documentUrl, 'https://cdn.swastik.com/doc.jpg');
      expect(entity.submittedAt, isNotNull);
      expect(entity.rejectionReason, isNull);

      // Unknown enum test
      const KycSubmitResponseDto unknownDto = KycSubmitResponseDto(
        referenceId: 'KYC-UNKNOWN',
        status: 'FUTURE_STATUS_CODE',
        documentType: 'VOTER_ID_UNKNOWN',
        documentNumberMasked: 'XXXX',
      );
      final KycResultEntity unknownEntity = KycMapper.toEntity(unknownDto);
      expect(unknownEntity.status, KycStatusEnum.unknown);
      expect(unknownEntity.documentType, DocTypeEnum.unknown);
    });

    test('5. MockKycRepository enforces 10MB limit and validations', () async {
      final MockKycRepository repo = MockKycRepository(
        initialStatus: KycStatusEnum.notSubmitted,
      );

      // Verify initial status
      final KycResultEntity initial = await repo.getKycStatus();
      expect(initial.status, KycStatusEnum.notSubmitted);

      // Rejects file > 10MB
      expect(
        () => repo.submitKyc(
          const KycSubmissionEntity(
            documentType: DocTypeEnum.aadhaar,
            documentNumber: '1234 5678 9012',
            consentAgreed: true,
            fileSizeBytes: 11 * 1024 * 1024, // 11 MB
          ),
        ),
        throwsA(isA<ValidationException>()),
      );

      // Rejects invalid Aadhaar
      expect(
        () => repo.submitKyc(
          const KycSubmissionEntity(
            documentType: DocTypeEnum.aadhaar,
            documentNumber: '12345',
            consentAgreed: true,
            fileSizeBytes: 1024,
          ),
        ),
        throwsA(isA<ValidationException>()),
      );

      // Rejects missing consent
      expect(
        () => repo.submitKyc(
          const KycSubmissionEntity(
            documentType: DocTypeEnum.aadhaar,
            documentNumber: '123456789012',
            consentAgreed: false,
            fileSizeBytes: 1024,
          ),
        ),
        throwsA(isA<ValidationException>()),
      );

      // Successful submission transitions to pending
      final KycResultEntity submitted = await repo.submitKyc(
        const KycSubmissionEntity(
          documentType: DocTypeEnum.aadhaar,
          documentNumber: '1234 5678 9012',
          consentAgreed: true,
          fileSizeBytes: 2 * 1024 * 1024,
        ),
      );
      expect(submitted.status, KycStatusEnum.pending);
      expect(submitted.documentNumberMasked, 'XXXX XXXX 9012');

      // Check configured mock status with rejection reason
      repo.setMockStatus(
        KycStatusEnum.rejected,
        rejectionReason: 'Document image was blurry. Please upload clear photo.',
      );
      final KycResultEntity rejected = await repo.getKycStatus();
      expect(rejected.status, KycStatusEnum.rejected);
      expect(rejected.rejectionReason, contains('blurry'));
    });
  });
}
