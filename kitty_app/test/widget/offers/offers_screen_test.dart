import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/core/providers/repository_providers.dart';
import 'package:kitty_app/features/home/data/repositories/mock_product_repository.dart';
import 'package:kitty_app/features/home/domain/entities/product_entity.dart';
import 'package:kitty_app/features/offers/data/repositories/mock_scheme_repository.dart';
import 'package:kitty_app/features/offers/domain/entities/scheme_entity.dart';
import 'package:kitty_app/features/offers/presentation/screens/offers_screen.dart';
import 'package:kitty_app/features/offers/presentation/widgets/offers_enrollment_dialog.dart';
import 'package:kitty_app/features/offers/presentation/widgets/offers_hero_header.dart';
import 'package:kitty_app/features/offers/presentation/widgets/offers_scheme_card.dart';
import 'package:kitty_app/features/offers/presentation/widgets/offers_trust_strip.dart';
import 'package:kitty_app/shared/widgets/feedback/kitty_empty_state.dart';

void main() {
  group('OffersScreen Widget Tests', () {
    final MockEngineConfig instantConfig =
        MockEngineConfig(latency: MockLatency.instant);

    Widget buildTestApp({
      required MockSchemeRepository schemeRepository,
      required MockProductRepository productRepository,
    }) {
      return ProviderScope(
        overrides: [
          schemeRepositoryProvider.overrideWithValue(schemeRepository),
          productRepositoryProvider.overrideWithValue(productRepository),
        ],
        child: const MaterialApp(
          home: OffersScreen(),
        ),
      );
    }

    testWidgets('1. Fully renders loaded Offers screen with hero header, switcher, tabs, cards, and trust strip',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository schemeRepo =
          MockSchemeRepository(engineConfig: instantConfig);
      final MockProductRepository productRepo =
          MockProductRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(
          schemeRepository: schemeRepo,
          productRepository: productRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Hero Header
      expect(find.byType(OffersHeroHeader), findsOneWidget);
      expect(find.text('CURATED GOLD SCHEME'), findsOneWidget);
      expect(find.text('Explore Our Gold Scheme'), findsOneWidget);

      // Section Switcher removed per Change 10
      expect(find.text('✦ Savings Schemes'), findsNothing);
      expect(find.text('💎 Jewellery Catalog'), findsNothing);

      // Duration Tabs
      expect(find.text('All Plans (3)'), findsOneWidget);
      expect(find.text('12 Months (1)'), findsOneWidget);
      expect(find.text('18 Months (1)'), findsOneWidget);

      // Scheme Cards
      expect(find.byType(OffersSchemeCard), findsWidgets);
      expect(find.text('Swastik Suvarna Varsha'), findsOneWidget);

      // Trust Strip
      expect(find.byType(OffersTrustStrip), findsOneWidget);
      expect(find.text('SWASTIK TRUST & SECURITY'), findsOneWidget);
      expect(find.text('100% BIS Hallmarked'), findsOneWidget);
    });

    testWidgets('2. Tapping duration filter tab filters visible scheme cards',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository schemeRepo =
          MockSchemeRepository(engineConfig: instantConfig);
      final MockProductRepository productRepo =
          MockProductRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(
          schemeRepository: schemeRepo,
          productRepository: productRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Initially all 3 schemes are visible
      expect(find.byType(OffersSchemeCard), findsNWidgets(3));

      // Tap 12 Months tab
      await tester.tap(find.text('12 Months (1)'));
      await tester.pumpAndSettle();

      // Only 1 scheme is 12-month in default mock
      expect(find.byType(OffersSchemeCard), findsOneWidget);
      expect(find.text('Swastik Suvarna Varsha'), findsOneWidget);

      // Tap All Plans tab to reset
      await tester.tap(find.text('All Plans (3)'));
      await tester.pumpAndSettle();

      expect(find.byType(OffersSchemeCard), findsNWidgets(3));
    });

    testWidgets('3. Tapping CTA button opens OffersEnrollmentDialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository schemeRepo =
          MockSchemeRepository(engineConfig: instantConfig);
      final MockProductRepository productRepo =
          MockProductRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(
          schemeRepository: schemeRepo,
          productRepository: productRepo,
        ),
      );
      await tester.pumpAndSettle();

      final Finder ctaFinder = find.text('START 12-MONTH GOLD SCHEME');
      expect(ctaFinder, findsOneWidget);

      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.byType(OffersEnrollmentDialog), findsOneWidget);
      expect(find.text('Enrol in Gold Scheme'), findsOneWidget);
      expect(find.text('CONFIRM & START GOLD SCHEME'), findsOneWidget);

      // Close dialog
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(OffersEnrollmentDialog), findsNothing);
    });

    testWidgets('4. Kitty Schemes page dedicated to savings: Jewellery catalog option is removed',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository schemeRepo =
          MockSchemeRepository(engineConfig: instantConfig);
      final MockProductRepository productRepo =
          MockProductRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(
          schemeRepository: schemeRepo,
          productRepository: productRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Schemes cards are shown
      expect(find.byType(OffersSchemeCard), findsWidgets);

      // Jewellery Catalog switcher/option is removed per Change 10
      expect(find.text('💎 Jewellery Catalog'), findsNothing);
      expect(find.text('✦ Savings Schemes'), findsNothing);

      // Swastik Trust Strip is rendered
      expect(find.text('100% BIS Hallmarked'), findsOneWidget);
    });

    testWidgets('6. Renders Empty State when no schemes or products exist',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository schemeRepo =
          MockSchemeRepository(engineConfig: instantConfig);
      final MockProductRepository productRepo =
          MockProductRepository(engineConfig: instantConfig);

      schemeRepo.setCustomSchemes(<SchemeEntity>[]);
      productRepo.setCustomProducts(<ProductEntity>[]);

      await tester.pumpWidget(
        buildTestApp(
          schemeRepository: schemeRepo,
          productRepository: productRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KittyEmptyState), findsOneWidget);
      expect(find.text('No Active Offers & Plans'), findsOneWidget);
      expect(find.text('REFRESH'), findsOneWidget);
    });

    testWidgets('7. Renders Error State and recovers upon tapping Try Again',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository schemeRepo =
          MockSchemeRepository(engineConfig: instantConfig);
      final MockProductRepository productRepo =
          MockProductRepository(engineConfig: instantConfig);

      schemeRepo.setShouldThrow(true);

      await tester.pumpWidget(
        buildTestApp(
          schemeRepository: schemeRepo,
          productRepository: productRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to Load Offers & Catalog'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);

      // Now resolve error and tap Try Again
      schemeRepo.setShouldThrow(false);
      await tester.tap(find.text('TRY AGAIN'));
      await tester.pumpAndSettle();

      expect(find.text('CURATED GOLD SCHEME'), findsOneWidget);
      expect(find.byType(OffersSchemeCard), findsWidgets);
    });

    testWidgets('8. Benefit-first presentation renders 11+1 bonus banner and math',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository schemeRepo =
          MockSchemeRepository(engineConfig: instantConfig);
      final MockProductRepository productRepo =
          MockProductRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(
          schemeRepository: schemeRepo,
          productRepository: productRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Check for 11+1 callout banner
      expect(find.text('✦ 11 + 1 SWASTIK BONUS BENEFIT'), findsOneWidget);
      expect(find.text('11+1 PLAN'), findsOneWidget);
      expect(find.text('View Plan Details & Rules'), findsWidgets);
    });

    testWidgets('9. Tapping View Plan Details & Rules opens KittyPlanDetailSheet with FAQs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final MockSchemeRepository schemeRepo =
          MockSchemeRepository(engineConfig: instantConfig);
      final MockProductRepository productRepo =
          MockProductRepository(engineConfig: instantConfig);

      await tester.pumpWidget(
        buildTestApp(
          schemeRepository: schemeRepo,
          productRepository: productRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Tap first "View Plan Details & Rules"
      await tester.tap(find.text('View Plan Details & Rules').first);
      await tester.pumpAndSettle();

      // Verify sheet content
      expect(find.text('KITTY PLAN DETAILS'), findsOneWidget);
      expect(find.text('MATURITY MATHEMATICS (11+1 ADVANTAGE)'), findsOneWidget);
      expect(find.text('HOW REDEMPTION WORKS'), findsOneWidget);
      expect(find.text('FREQUENTLY ASKED QUESTIONS'), findsOneWidget);
      expect(find.text('START SWASTIK SUVARNA VARSHA NOW'), findsOneWidget);

      // Tap START ... NOW from sheet opens enrollment dialog
      await tester.tap(find.text('START SWASTIK SUVARNA VARSHA NOW'));
      await tester.pumpAndSettle();

      expect(find.byType(OffersEnrollmentDialog), findsOneWidget);
    });
  });
}
