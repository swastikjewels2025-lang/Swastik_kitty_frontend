import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import 'dashboard_hero_card.dart';

/// Luxury multi-scheme carousel allowing patrons with multiple active Kitty plans
/// to seamlessly view, swipe between, inspect, and pay for each scheme independently.
class DashboardMultiSchemeCarousel extends StatefulWidget {
  const DashboardMultiSchemeCarousel({
    super.key,
    required this.schemes,
    required this.selectedIndex,
    required this.onSchemeChanged,
    required this.onPaySelected,
    this.onViewPassbook,
    this.onViewDetails,
  });

  final List<DashboardSummaryEntity> schemes;
  final int selectedIndex;
  final ValueChanged<int> onSchemeChanged;
  final ValueChanged<DashboardSummaryEntity> onPaySelected;
  final ValueChanged<DashboardSummaryEntity>? onViewPassbook;
  final ValueChanged<DashboardSummaryEntity>? onViewDetails;

  @override
  State<DashboardMultiSchemeCarousel> createState() =>
      _DashboardMultiSchemeCarouselState();
}

class _DashboardMultiSchemeCarouselState
    extends State<DashboardMultiSchemeCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.selectedIndex.clamp(0, widget.schemes.length - 1),
    );
  }

  @override
  void didUpdateWidget(covariant DashboardMultiSchemeCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        _pageController.hasClients &&
        _pageController.page?.round() != widget.selectedIndex) {
      _pageController.animateToPage(
        widget.selectedIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schemes.isEmpty) {
      return const SizedBox.shrink();
    }

    // Single scheme display optimization
    if (widget.schemes.length == 1) {
      final DashboardSummaryEntity singleScheme = widget.schemes.first;
      return DashboardHeroCard(
        dashboard: singleScheme,
        onPayTap: () => widget.onPaySelected(singleScheme),
      );
    }

    final int activeIndex = widget.selectedIndex.clamp(0, widget.schemes.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 1. Multi-Scheme Portfolio Header & Horizontal Tab Pills
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.collections_bookmark_outlined,
                        size: 14,
                        color: AppColors.honeyGoldAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ACTIVE SCHEMES (${widget.schemes.length})',
                        style: AppTypography.kickerCaps(
                          color: AppColors.honeyGoldAccent,
                        ).copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Swipe card or tap tab',
                    style: AppTypography.bodySmall(
                      color: AppColors.textTertiary,
                    ).copyWith(fontSize: 10.5),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space8),

              // Selector Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List<Widget>.generate(widget.schemes.length, (int index) {
                    final DashboardSummaryEntity s = widget.schemes[index];
                    final bool isSelected = index == activeIndex;
                    final int emi = s.customMonthlyEmi ?? 5000;
                    final String formattedEmi = CurrencyFormatter.formatRupees(emi);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        key: Key('multi_scheme_tab_$index'),
                        onTap: () {
                          widget.onSchemeChanged(index);
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        borderRadius: AppRadius.border12,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryEmerald
                                : AppColors.surfaceCardBg,
                            borderRadius: AppRadius.border12,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.honeyGoldAccent
                                  : AppColors.surfaceCardBorder,
                              width: isSelected ? 1.4 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? const <BoxShadow>[
                                    BoxShadow(
                                      color: Color(0x1A063B2C),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.savings_outlined,
                                size: 13,
                                color: isSelected
                                    ? AppColors.honeyGoldAccent
                                    : AppColors.textSecondaryMuted,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Kitty #${index + 1}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight:
                                      isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.espressoCharcoal,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedEmi,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.honeyGoldAccent
                                      : AppColors.primaryEmerald,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.space6),

        // 2. Swipeable Scheme Card Carousel
        SizedBox(
          height: 470,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.schemes.length,
            onPageChanged: widget.onSchemeChanged,
            itemBuilder: (BuildContext context, int index) {
              final DashboardSummaryEntity scheme = widget.schemes[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (BuildContext context, Widget? child) {
                  return DashboardHeroCard(
                    dashboard: scheme,
                    onPayTap: () => widget.onPaySelected(scheme),
                  );
                },
              );
            },
          ),
        ),

        // 3. Carousel Dots Indicator
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(widget.schemes.length, (int index) {
              final bool isSelected = index == activeIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.honeyGoldAccent
                      : AppColors.surfaceCardBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
