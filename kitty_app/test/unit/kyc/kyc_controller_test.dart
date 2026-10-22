import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/kyc/data/repositories/mock_kyc_repository.dart';
import 'package:kitty_app/features/kyc/domain/entities/kyc_entity.dart';
import 'package:kitty_app/features/kyc/presentation/providers/kyc_controller.dart';
import 'package:kitty_app/features/kyc/presentation/providers/kyc_state.dart';

void main() {
  group('KycController & Riverpod State Suite', () {
    late MockKycRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockKycRepository(initialStatus: KycStatusEnum.notSubmitted);
      container = ProviderContainer(
        overrides: [
          kycRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('1. Initial state and loadKycStatus notSubmitted', () async {
      final KycController controller =
          container.read(kycControllerProvider.notifier);

      expect(container.read(kycControllerProvider).status, KycFormStatus.initial);

      await controller.loadKycStatus();
      final KycState state = container.read(kycControllerProvider);

      expect(state.status, KycFormStatus.notSubmitted);
      expect(state.selectedDocType, DocTypeEnum.aadhaar);
      expect(state.canSubmit, isFalse);
    });

    test('2. loadKycStatus handles verified, pending, and rejected states', () async {
      final KycController controller =
          container.read(kycControllerProvider.notifier);

      // Verified
      mockRepo.setMockStatus(KycStatusEnum.verified);
      await controller.loadKycStatus();
      expect(container.read(kycControllerProvider).status, KycFormStatus.verified);

      // Pending
      mockRepo.setMockStatus(KycStatusEnum.pending);
      await controller.loadKycStatus();
      expect(container.read(kycControllerProvider).status, KycFormStatus.pending);

      // Rejected
      mockRepo.setMockStatus(
        KycStatusEnum.rejected,
        rejectionReason: 'Blurry document image.',
      );
      await controller.loadKycStatus();
      final KycState rejectedState = container.read(kycControllerProvider);
      expect(rejectedState.status, KycFormStatus.rejected);
      expect(rejectedState.kycResult?.rejectionReason, contains('Blurry'));
    });

    test('3. selectDocType switches tab and clears document number', () {
      final KycController controller =
          container.read(kycControllerProvider.notifier);

      controller.updateDocNumber('1234 5678 9012');
      expect(container.read(kycControllerProvider).isDocNumberValid, isTrue);

      controller.selectDocType(DocTypeEnum.pan);
      final KycState state = container.read(kycControllerProvider);

      expect(state.selectedDocType, DocTypeEnum.pan);
      expect(state.documentNumber, isEmpty);
      expect(state.isDocNumberValid, isFalse);
    });

    test('4. updateDocNumber validates Aadhaar and PAN correctly', () {
      final KycController controller =
          container.read(kycControllerProvider.notifier);

      // Aadhaar
      controller.updateDocNumber('1234 5678 901'); // 11 digits
      expect(container.read(kycControllerProvider).isDocNumberValid, isFalse);

      controller.updateDocNumber('1234 5678 9012'); // 12 digits
      expect(container.read(kycControllerProvider).isDocNumberValid, isTrue);

      // PAN
      controller.selectDocType(DocTypeEnum.pan);
      controller.updateDocNumber('abcde1234f'); // lowercase handles uppercase
      expect(container.read(kycControllerProvider).documentNumber, 'ABCDE1234F');
      expect(container.read(kycControllerProvider).isDocNumberValid, isTrue);

      controller.updateDocNumber('ABCDE12345'); // invalid ending digit
      expect(container.read(kycControllerProvider).isDocNumberValid, isFalse);
    });

    test('5. setFile, removeFile, and 10MB limit handling', () {
      final KycController controller =
          container.read(kycControllerProvider.notifier);

      const SelectedKycFile validFile = SelectedKycFile(
        name: 'passport.jpg',
        path: '/tmp/passport.jpg',
        sizeBytes: 2 * 1024 * 1024,
        mimeType: 'image/jpeg',
      );
      controller.setFile(validFile);
      expect(container.read(kycControllerProvider).selectedFile, isNotNull);
      expect(container.read(kycControllerProvider).errorMessage, isNull);

      // Exceeds 10MB limit
      const SelectedKycFile largeFile = SelectedKycFile(
        name: 'huge_scan.png',
        path: '/tmp/huge_scan.png',
        sizeBytes: 12 * 1024 * 1024, // 12 MB
        mimeType: 'image/png',
      );
      controller.setFile(largeFile);
      expect(
        container.read(kycControllerProvider).errorMessage,
        contains('exceeds 10MB'),
      );

      controller.removeFile();
      expect(container.read(kycControllerProvider).selectedFile, isNull);
    });

    test('6. Consent toggle, canSubmit property, and submission flow', () async {
      final KycController controller =
          container.read(kycControllerProvider.notifier);

      // Setup valid form
      controller.updateDocNumber('1234 5678 9012');
      controller.setFile(
        const SelectedKycFile(
          name: 'aadhaar.jpg',
          path: '/tmp/aadhaar.jpg',
          sizeBytes: 1024 * 500,
          mimeType: 'image/jpeg',
        ),
      );

      // Without consent
      expect(container.read(kycControllerProvider).canSubmit, isFalse);

      // With consent
      controller.toggleConsent(true);
      expect(container.read(kycControllerProvider).canSubmit, isTrue);

      // Submit
      final bool success = await controller.submitKyc();
      expect(success, isTrue);

      final KycState submittedState = container.read(kycControllerProvider);
      expect(submittedState.status, KycFormStatus.pending);
      expect(submittedState.kycResult?.status, KycStatusEnum.pending);
      expect(submittedState.kycResult?.documentNumberMasked, contains('9012'));
    });

    test('7. retry() resets back to notSubmitted state', () {
      final KycController controller =
          container.read(kycControllerProvider.notifier);

      controller.setMockFormStatus(KycFormStatus.rejected);
      expect(container.read(kycControllerProvider).status, KycFormStatus.rejected);

      controller.retry();
      expect(container.read(kycControllerProvider).status, KycFormStatus.notSubmitted);
    });
  });
}
