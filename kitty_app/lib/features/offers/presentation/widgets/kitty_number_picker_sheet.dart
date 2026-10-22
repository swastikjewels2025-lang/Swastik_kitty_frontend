import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/badges/kitty_number_pill.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';
import '../../../../shared/widgets/feedback/kitty_empty_state.dart';
import '../../../../shared/widgets/feedback/kitty_error_state.dart';
import '../../../../shared/widgets/inputs/kitty_search_field.dart';
import '../../domain/entities/kitty_slot_entity.dart';
import '../../domain/entities/scheme_entity.dart';
import '../providers/kitty_number_picker_controller.dart';
import '../providers/kitty_number_picker_state.dart';

/// Modal bottom sheet presenting the interactive 50-slot Kitty Number selection matrix.
///
/// Features:
/// - Triple-encoded status indicators (Color + Icon/Shape + Text)
/// - Real-time lucky number search & quick preset chips
/// - Local 15-minute optimistic hold lock
/// - Minimum 52px touch targets with accessible semantics
class KittyNumberPickerSheet extends ConsumerStatefulWidget {
  const KittyNumberPickerSheet({
    super.key,
    required this.scheme,
    this.initialSelectedNumber,
    required this.onNumberSelected,
  });

  final SchemeEntity scheme;
  final int? initialSelectedNumber;
  final ValueChanged<KittySlotEntity> onNumberSelected;

  /// Helper to launch the slot picker as a modal bottom sheet.
  static Future<KittySlotEntity?> show(
    BuildContext context, {
    required SchemeEntity scheme,
    int? initialSelectedNumber,
  }) {
    return showModalBottomSheet<KittySlotEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => KittyNumberPickerSheet(
        scheme: scheme,
        initialSelectedNumber: initialSelectedNumber,
        onNumberSelected: (KittySlotEntity slot) {
          Navigator.of(ctx).pop(slot);
        },
      ),
    );
  }

  @override
  ConsumerState<KittyNumberPickerSheet> createState() =>
      _KittyNumberPickerSheetState();
}

class _KittyNumberPickerSheetState
    extends ConsumerState<KittyNumberPickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(kittyNumberPickerControllerProvider.notifier)
          .loadSlots(widget.scheme.id);
      if (widget.initialSelectedNumber != null && mounted) {
        ref
            .read(kittyNumberPickerControllerProvider.notifier)
            .selectLuckyNumber(widget.initialSelectedNumber!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final KittyNumberPickerState state =
        ref.watch(kittyNumberPickerControllerProvider);
    final KittyNumberPickerController controller =
        ref.read(kittyNumberPickerControllerProvider.notifier);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            // 1. Drag Handle & Header
            _buildHeader(context),
            const Divider(height: 1, color: Color(0xFFEFE5D8)),

            // 2. Main Content
            Expanded(
              child: switch (state.status) {
                KittyNumberPickerStatus.initial ||
                KittyNumberPickerStatus.loading =>
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF09362C),
                    ),
                  ),
                KittyNumberPickerStatus.error => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space24),
                      child: KittyErrorState(
                        title: 'Unable to Load Kitty Numbers',
                        message: state.errorMessage ??
                            'Please check connection and try again.',
                        retryLabel: 'Try Again',
                        onRetry: controller.retry,
                      ),
                    ),
                  ),
                KittyNumberPickerStatus.loaded => _buildLoadedView(
                    context,
                    state,
                    controller,
                  ),
              },
            ),

            // 3. Sticky Bottom Confirmation Bar
            _buildBottomBar(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE9CE),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF8F5824),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'CHOOSE LUCKY KITTY NUMBER',
                    style: AppTypography.caption(
                      color: const Color(0xFF8F5824),
                    ).copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Select Your Numbers',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF6B665E),
              size: 22,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedView(
    BuildContext context,
    KittyNumberPickerState state,
    KittyNumberPickerController controller,
  ) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Draw Info & Price Pill Box from book.html
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEFE5D8)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x05000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBE9CE),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Draw #25',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: const Color(0xFFE5DDCF),
                      ),
                      RichText(
                        text: const TextSpan(
                          text: '₹100 ',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1E1E),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '/ number',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B665E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Field
                KittySearchField(
                  controller: _searchController,
                  hintText: 'Search lucky number (e.g. 7, 21, 51)...',
                  onChanged: controller.search,
                ),
                const SizedBox(height: 10),

                // Quick Lucky Number Preset Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      const Text(
                        'Auspicious: ',
                        style: TextStyle(
                          color: Color(0xFF8F5824),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildPresetChip('No. 7', 7, controller),
                      _buildPresetChip('No. 9', 9, controller),
                      _buildPresetChip('No. 21', 21, controller),
                      _buildPresetChip('No. 51', 51, controller),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Status Legend Bar
                _buildLegendBar(state),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // Grid of 50 Slots
        if (state.filteredSlots.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: KittyEmptyState(
              title: 'No Matching Numbers',
              description: 'Try searching for another number between 1 and 50.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext ctx, int index) {
                  final KittySlotEntity slot = state.filteredSlots[index];
                  final bool isSelected =
                      state.selectedSlot?.number == slot.number;
                  return _buildSlotTile(ctx, slot, isSelected, controller);
                },
                childCount: state.filteredSlots.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.space24),
        ),
      ],
    );
  }

  Widget _buildPresetChip(
    String label,
    int number,
    KittyNumberPickerController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(
          color: Color(0xFF8F5824),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: const Color(0xFFFBE9CE),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        side: const BorderSide(color: Color(0xFFEFE5D8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onPressed: () {
          _searchController.text = number.toString();
          controller.search(number.toString());
          controller.selectLuckyNumber(number);
        },
      ),
    );
  }

  Widget _buildLegendBar(KittyNumberPickerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEFE5D8)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runAlignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 4,
        children: <Widget>[
          _buildLegendDot(
            color: const Color(0xFFE5DDCF),
            label: 'Available (${state.availableCount})',
          ),
          _buildLegendDot(
            color: const Color(0xFF09362C),
            label: 'Your Selection',
          ),
          _buildLegendDot(
            color: const Color(0xFFBFBAB0),
            label: 'Booked (${state.bookedCount})',
          ),
          if (state.lockedCount > 0)
            _buildLegendDot(
              color: const Color(0xFF8F5824),
              label: 'Held (${state.lockedCount})',
            ),
        ],
      ),
    );
  }

  Widget _buildLegendDot({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x33000000), width: 0.5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B665E),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotTile(
    BuildContext context,
    KittySlotEntity slot,
    bool isSelected,
    KittyNumberPickerController controller,
  ) {
    final String formattedNum = slot.number.toString().padLeft(2, '0');

    // Visual configurations based on state
    Color bgColor;
    Color borderColor;
    Color textColor;
    Widget? iconBadge;

    if (isSelected) {
      bgColor = const Color(0xFF09362C);
      borderColor = const Color(0xFF062820);
      textColor = Colors.white;
      iconBadge = const Icon(
        Icons.check_circle_rounded,
        size: 13,
        color: Color(0xFFD4B886),
      );
    } else if (slot.isBooked) {
      bgColor = const Color(0xFFBFBAB0);
      borderColor = const Color(0xFFAFA99E);
      textColor = const Color(0xFF6B665E);
      iconBadge = const Icon(
        Icons.lock_outline_rounded,
        size: 11,
        color: Color(0xFF6B665E),
      );
    } else if (slot.isLocked) {
      bgColor = const Color(0xFFFBE9CE);
      borderColor = const Color(0xFFD4B886);
      textColor = const Color(0xFF8F5824);
      iconBadge = const Icon(
        Icons.hourglass_top_rounded,
        size: 11,
        color: Color(0xFF8F5824),
      );
    } else {
      // Available
      bgColor = const Color(0xFFF6F1E8);
      borderColor = const Color(0xFFE5DDD0);
      textColor = const Color(0xFF1E1E1E);
    }

    return Semantics(
      label:
          'Kitty Number $formattedNum, ${isSelected ? 'Selected' : slot.status.name}',
      button: slot.isAvailable,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (slot.isBooked) {
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Kitty Number #$formattedNum is already booked by another patron.',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (slot.isLocked) {
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Kitty Number #$formattedNum is temporarily reserved in another checkout.',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              HapticFeedback.selectionClick();
              controller.selectSlot(slot);
            }
          },
          borderRadius: AppRadius.border12,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.border12,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2.0 : 1.2,
              ),
              boxShadow: isSelected
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x33063D2E),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Text(
                    formattedNum,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                if (iconBadge != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: iconBadge,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, KittyNumberPickerState state) {
    final KittySlotEntity? selected = state.selectedSlot;
    final bool hasSelection = selected != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCardBg,
        border: Border(
          top: BorderSide(color: AppColors.warmLinenInset, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (hasSelection)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text(
                        'SELECTED: ',
                        style: TextStyle(
                          color: AppColors.warmTaupeBrown,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      KittyNumberPill(
                        number: selected.tokenString,
                        isDarkSurface: false,
                      ),
                    ],
                  ),
                  const Text(
                    '🔒 Held 15 Mins',
                    style: TextStyle(
                      color: AppColors.primaryEmerald,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          KittyPrimaryButton(
            label: hasSelection
                ? 'CONTINUE WITH NUMBER ${selected.number} →'
                : 'SELECT A LUCKY NUMBER',
            isEnabled: hasSelection,
            height: 52,
            onPressed: hasSelection
                ? () {
                    widget.onNumberSelected(selected);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
