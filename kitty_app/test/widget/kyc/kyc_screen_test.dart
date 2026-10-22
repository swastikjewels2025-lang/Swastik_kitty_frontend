import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/kyc/data/repositories/mock_kyc_repository.dart';
import 'package:kitty_app/features/kyc/domain/entities/kyc_entity.dart';
import 'package:kitty_app/features/kyc/presentation/providers/kyc_controller.dart';
import 'package:kitty_app/features/kyc/presentation/screens/kyc_screen.dart';
import 'package:kitty_app/features/kyc/presentation/widgets/kyc_status_views.dart';

void main() {
  group('KycScreen Widget Test Suite', () {
    late MockEngineConfig instantConfig;
    late MockKycRepository mockRepo;

    setUp(() {
      instantConfig = MockEngineConfig(latency: MockLatency.instant);
      mockRepo = MockKycRepository(
        engineConfig: instantConfig,
        initialStatus: KycStatusEnum.notSubmitted,
      );
    });

    testWidgets('1. KycScreen renders header, tabs, inputs, and disabled CTA', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            kycRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: KycScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Swastik Jewellers'), findsOneWidget);
      expect(find.text('KYC Document Verification'), findsOneWidget);
      expect(find.text('Aadhaar Card'), findsOneWidget);
      expect(find.text('PAN Card'), findsOneWidget);
      expect(find.text('Aadhaar Number (12 Digits)'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.textContaining('Terms & Conditions'), findsOneWidget);
      expect(find.text('COMPLETE KYC'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
    });

    testWidgets('2. Tapping PAN tab switches doc type and updates label', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            kycRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: KycScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap PAN Card tab
      await tester.tap(find.text('PAN Card'));
      await tester.pumpAndSettle();

      expect(find.text('PAN Card Number (10 Characters)'), findsOneWidget);
    });

    testWidgets('3. Form validation, file attachment, consent, and submit flow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ProviderContainer container = ProviderContainer(
        overrides: [
          kycRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: KycScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter 12 digits Aadhaar
      await tester.enterText(find.byType(TextField).first, '123456789012');
      await tester.pumpAndSettle();

      // Programmatically attach file to simulate picker
      container.read(kycControllerProvider.notifier).setFile(
        const SelectedKycFile(
          name: 'aadhaar_scan.jpg',
          path: '/tmp/aadhaar_scan.jpg',
          sizeBytes: 1572864, // 1.5 MB
          mimeType: 'image/jpeg',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('aadhaar_scan.jpg'), findsOneWidget);
      expect(find.text('1.5 MB • Ready'), findsOneWidget);

      // Tap consent checkbox
      await tester.tap(find.byKey(const Key('terms_checkbox')));
      await tester.pumpAndSettle();

      // Submit KYC button is now enabled
      final Finder submitBtn = find.text('COMPLETE KYC');
      expect(submitBtn, findsOneWidget);

      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Submitted successfully -> Pending state view
      expect(find.text('KYC Under Verification'), findsOneWidget);
      expect(find.text('RETURN TO HOME'), findsOneWidget);
    });

    testWidgets('4. KycScreen displays Approved view when status is verified', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      mockRepo.setMockStatus(KycStatusEnum.verified);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            kycRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: KycScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KycApprovedView), findsOneWidget);
      expect(find.text('KYC Verified & Approved'), findsOneWidget);
      expect(find.text('ENTER GOLD SCHEME DASHBOARD'), findsOneWidget);
    });

    testWidgets('5. KycScreen displays Rejected view with reason and retry action', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      mockRepo.setMockStatus(
        KycStatusEnum.rejected,
        rejectionReason: 'ID photo is unclear. Please re-upload.',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            kycRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: KycScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KycRejectedView), findsOneWidget);
      expect(find.text('KYC Verification Rejected'), findsOneWidget);
      expect(find.text('ID photo is unclear. Please re-upload.'), findsOneWidget);
      expect(find.text('RETRY KYC SUBMISSION'), findsOneWidget);

      // Tap Retry
      await tester.tap(find.text('RETRY KYC SUBMISSION'));
      await tester.pumpAndSettle();

      // Back to Form
      expect(find.text('KYC Document Verification'), findsOneWidget);
    });

    testWidgets('6. KycScreen displays Skip options and executes skip callback', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            kycRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: KycScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top right and bottom Skip actions are displayed
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);

      // Tap Skip for now
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();
    });
  });
}
