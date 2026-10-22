import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/kyc/data/repositories/mock_kyc_repository.dart';
import 'package:kitty_app/features/kyc/presentation/screens/kyc_screen.dart';

void main() {
  group('KycScreen Responsive & Keyboard Test Suite', () {
    late MockEngineConfig instantConfig;
    late MockKycRepository mockRepo;

    setUp(() {
      instantConfig = MockEngineConfig(latency: MockLatency.instant);
      mockRepo = MockKycRepository(
        engineConfig: instantConfig,
        initialStatus: KycStatusEnum.notSubmitted,
      );
    });

    final List<Size> testSizes = <Size>[
      const Size(320, 568), // iPhone SE / Small Android
      const Size(360, 640), // Typical compact Android
      const Size(375, 812), // Standard iPhone
      const Size(390, 844), // iPhone 13/14
      const Size(412, 915), // Pixel 7
      const Size(430, 932), // iPhone Pro Max
      const Size(768, 1024), // iPad / Tablet
    ];

    for (final Size size in testSizes) {
      testWidgets('Renders without overflow on ${size.width}x${size.height}', (WidgetTester tester) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
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

        expect(find.text('KYC Document Verification'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Handles open keyboard with insets without bottom overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;
      // Simulate 320px soft keyboard opening
      tester.view.viewInsets = const FakeViewPadding(bottom: 640);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

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

      // Tap on TextField to ensure focus
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
