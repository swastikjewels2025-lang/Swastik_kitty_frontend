import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/constants/app_colors.dart';
import 'package:kitty_app/core/constants/app_dimensions.dart';
import 'package:kitty_app/core/constants/app_icons.dart';
import 'package:kitty_app/core/constants/app_spacing.dart';
import 'package:kitty_app/core/constants/app_strings.dart';
import 'package:kitty_app/core/constants/app_typography.dart';
import 'package:kitty_app/core/theme/app_theme.dart';
import 'package:kitty_app/shared/widgets/badges/kitty_number_pill.dart';
import 'package:kitty_app/shared/widgets/display/kitty_section_header.dart';

void main() {
  group('Phase 2 Design System & Token Tests', () {
    test('AppColors provides all canonical semantic tokens', () {
      expect(AppColors.primary, equals(AppColors.primaryEmerald));
      expect(AppColors.primaryContainer, equals(AppColors.emeraldPrimary));
      expect(AppColors.surface, equals(AppColors.pureWhite));
      expect(AppColors.surfaceVariant, equals(AppColors.warmLinenInset));
      expect(AppColors.background, equals(AppColors.warmPearl));
      expect(AppColors.textPrimary, equals(AppColors.deepForestCharcoal));
      expect(AppColors.textSecondary, equals(AppColors.mutedSlateGray));
      expect(AppColors.textMuted, equals(AppColors.mutedNavGray));
      expect(AppColors.border, equals(AppColors.surfaceCardBorder));
      expect(AppColors.success, equals(AppColors.vibrantEmerald));
      expect(AppColors.warning, equals(AppColors.statusWarningText));
      expect(AppColors.error, equals(AppColors.statusErrorText));
      expect(AppColors.info, equals(const Color(0xFF2563EB)));
      expect(AppColors.gold, equals(AppColors.richAntiqueGold));
      expect(AppColors.silver, equals(const Color(0xFF94A3B8)));
    });

    test('AppTypography provides all required semantic text styles', () {
      expect(AppTypography.display().fontSize, equals(24.0));
      expect(AppTypography.headline().fontSize, equals(22.0));
      expect(AppTypography.title().fontSize, equals(17.0));
      expect(AppTypography.sectionTitle().fontSize, equals(15.0));
      expect(AppTypography.body().fontSize, equals(14.0));
      expect(AppTypography.bodyMedium().fontSize, equals(13.5));
      expect(AppTypography.bodySmall().fontSize, equals(12.0));
      expect(AppTypography.label().fontSize, equals(11.5));
      expect(AppTypography.caption().fontSize, equals(11.0));
      expect(AppTypography.button().fontSize, equals(14.0));
    });

    test('AppDimensions enforces 52px primary button and 48px touch target', () {
      expect(AppDimensions.primaryButtonHeight, equals(52.0));
      expect(AppDimensions.minTouchTarget, equals(48.0));
    });

    test('AppSpacing and AppRadius provide standard scale tokens', () {
      expect(AppSpacing.space16, equals(16.0));
      expect(AppSpacing.space24, equals(24.0));
      expect(AppRadius.radius12, equals(12.0));
      expect(AppRadius.radius14, equals(14.0));
      expect(AppRadius.radius18, equals(18.0));
      expect(AppRadius.radius20, equals(20.0));
      expect(AppRadius.radiusPill, equals(999.0));
    });

    test('AppIcons defines all canonical rounded icons', () {
      expect(AppIcons.home, equals(Icons.home_rounded));
      expect(AppIcons.liveRates, equals(Icons.trending_up_rounded));
      expect(AppIcons.myKitty, equals(Icons.account_balance_wallet_rounded));
      expect(AppIcons.kittyPlans, equals(Icons.savings_rounded));
      expect(AppIcons.calculator, equals(Icons.calculate_rounded));
      expect(AppIcons.jewellery, equals(Icons.diamond_rounded));
      expect(AppIcons.tag, equals(Icons.tag));
      expect(AppIcons.search, equals(Icons.search_rounded));
    });

    test('AppStrings centralizes all simplified and aligned UI terminology', () {
      expect(AppStrings.monthlyPayment, equals('Monthly Payment'));
      expect(AppStrings.kittyPlan, equals('Kitty Plan'));
      expect(AppStrings.kittyPlans, equals('Kitty Plans'));
      expect(AppStrings.myKitty, equals('My Kitty'));
      expect(AppStrings.activeKitty, equals('Active Kitty'));
      expect(AppStrings.savingsHistory, equals('Savings History'));
      expect(AppStrings.kittyNumber, equals('Kitty Number'));
      expect(AppStrings.kittyId, equals('Kitty ID'));
      expect(AppStrings.totalGoldGoal, equals('Total Gold Goal'));
      expect(AppStrings.startKitty, equals('Start Kitty'));
      expect(AppStrings.checkingWithBank, equals('Checking with Bank'));
      expect(AppStrings.readyToStart, equals('Ready to Start'));
      expect(AppStrings.idVerification, equals('ID Verification'));
    });

    test('ThemeData builds correctly for both dark and light variants', () {
      final ThemeData dark = AppTheme.darkTheme;
      final ThemeData light = AppTheme.lightTheme;

      expect(dark.brightness, equals(Brightness.dark));
      expect(light.brightness, equals(Brightness.light));
      expect(dark.elevatedButtonTheme.style?.minimumSize?.resolve(<WidgetState>{})?.height, equals(52.0));
      expect(light.elevatedButtonTheme.style?.minimumSize?.resolve(<WidgetState>{})?.height, equals(52.0));
    });
  });

  group('KittyNumberPill Widget Tests', () {
    testWidgets('renders number pill with default tag icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KittyNumberPill(number: 'No. 42'),
          ),
        ),
      );

      expect(find.text('No. 42'), findsOneWidget);
      expect(find.byIcon(AppIcons.tag), findsOneWidget);
    });
  });

  group('KittySectionHeader Enhanced Widget Tests', () {
    testWidgets('renders subtitle, custom trailing, and decorative bar', (WidgetTester tester) async {
      bool trailingTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KittySectionHeader(
              title: 'Active Kitty Plans',
              eyebrow: 'YOUR SAVINGS',
              subtitle: 'Track your monthly gold accumulation',
              showDecorativeBar: true,
              trailing: TextButton(
                onPressed: () => trailingTapped = true,
                child: const Text('View All'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('ACTIVE KITTY PLANS'), findsNothing);
      expect(find.text('Active Kitty Plans'), findsOneWidget);
      expect(find.text('YOUR SAVINGS'), findsOneWidget);
      expect(find.text('Track your monthly gold accumulation'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);

      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(trailingTapped, isTrue);
    });
  });
}
