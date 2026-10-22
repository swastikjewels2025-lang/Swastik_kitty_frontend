import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'dart:async';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/badges/kitty_number_pill.dart';
import '../../../../shared/widgets/buttons/kitty_primary_button.dart';
import '../../../../shared/widgets/feedback/kitty_empty_state.dart';
import '../../../../shared/widgets/feedback/kitty_error_state.dart';
import '../../../../shared/widgets/inputs/kitty_search_field.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../../domain/entities/kitty_slot_entity.dart';
import '../../domain/entities/scheme_entity.dart';
import '../providers/kitty_number_picker_controller.dart';
import '../providers/kitty_number_picker_state.dart';
import '../providers/start_kitty_flow_controller.dart';
import '../providers/start_kitty_flow_state.dart';

/// Comprehensive 3-step guided Start Kitty enrollment flow bottom sheet.
///
/// Steps:
/// 1. Plan Customization & 11+1 financial math preview.
/// 2. Interactive 50-slot Kitty Number selection matrix.
/// 3. Confirmation summary review & Month 1 checkout handoff.
class StartKittyFlowSheet extends ConsumerStatefulWidget {
  const StartKittyFlowSheet({
    super.key,
    required this.scheme,
    this.initialSlotNumber,
    this.customMonthlyAmount,
    this.sourceGrams,
    this.sourceKarat,
    this.onCompleted,
  });

  final SchemeEntity scheme;
  final int? initialSlotNumber;
  final int? customMonthlyAmount;
  final double? sourceGrams;
  final String? sourceKarat;
  final ValueChanged<Map<String, dynamic>>? onCompleted;

  static Future<void> show(
    BuildContext context, {
    required SchemeEntity scheme,
    int? initialSlotNumber,
    int? customMonthlyAmount,
    double? sourceGrams,
    String? sourceKarat,
    ValueChanged<Map<String, dynamic>>? onCompleted,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => StartKittyFlowSheet(
        scheme: scheme,
        initialSlotNumber: initialSlotNumber,
        customMonthlyAmount: customMonthlyAmount,
        sourceGrams: sourceGrams,
        sourceKarat: sourceKarat,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  ConsumerState<StartKittyFlowSheet> createState() => _StartKittyFlowSheetState();
}

class _StartKittyFlowSheetState extends ConsumerState<StartKittyFlowSheet> {
  final TextEditingController _amountInputController = TextEditingController();
  final TextEditingController _slotSearchController = TextEditingController();

  static const List<int> _amountPresets = <int>[2000, 3000, 5000, 10000];

  @override
  void initState() {
    super.initState();
    final int initialAmount =
        widget.customMonthlyAmount ?? widget.scheme.monthlyInstallment;
    _amountInputController.text = initialAmount.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(startKittyFlowControllerProvider.notifier).init(
            widget.scheme,
            customMonthlyAmount: widget.customMonthlyAmount,
            sourceGrams: widget.sourceGrams,
            sourceKarat: widget.sourceKarat,
          );
      await ref
          .read(kittyNumberPickerControllerProvider.notifier)
          .loadSlots(widget.scheme.id);
      if (widget.initialSlotNumber != null && mounted) {
        ref
            .read(kittyNumberPickerControllerProvider.notifier)
            .selectLuckyNumber(widget.initialSlotNumber!);
      }
    });
  }

  @override
  void dispose() {
    _amountInputController.dispose();
    _slotSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StartKittyFlowState flowState =
        ref.watch(startKittyFlowControllerProvider);
    final StartKittyFlowController flowController =
        ref.read(startKittyFlowControllerProvider.notifier);

    return Container(
      key: const Key('start_kitty_flow_sheet'),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            // 1. Drag Handle & Sheet Header
            _buildHeader(context, flowState, flowController),
            const Divider(height: 1, color: AppColors.warmLinenInset),

            // 2. Stepper Header Indicator
            _buildStepper(flowState),
            const Divider(height: 1, color: AppColors.warmLinenInset),

            // 3. Step Body
            Expanded(
              child: switch (flowState.currentStep) {
                StartKittyStep.planCustomization =>
                  _buildStep1PlanCustomization(context, flowState, flowController),
                StartKittyStep.numberSelection =>
                  _buildStep2NumberSelection(context, flowState, flowController),
                StartKittyStep.confirmation =>
                  _buildStep3Confirmation(context, flowState, flowController),
              },
            ),

            // 4. Sticky Bottom Action Bar
            _buildStickyBottomBar(context, flowState, flowController),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    StartKittyFlowState flowState,
    StartKittyFlowController flowController,
  ) {
    final String stepTitle = switch (flowState.currentStep) {
      StartKittyStep.planCustomization => 'Step 1: Customize Your Plan',
      StartKittyStep.numberSelection => 'Step 2: Choose Kitty Number',
      StartKittyStep.confirmation => 'Step 3: Review & Confirm',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (flowState.currentStep != StartKittyStep.planCustomization)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.deepUmberBronze,
                    size: 22,
                  ),
                  onPressed: flowController.previousStep,
                  tooltip: 'Go Back',
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    stepTitle,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepEmeraldBase,
                    ),
                  ),
                  Text(
                    widget.scheme.name,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.warmTaupeBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            key: const Key('start_kitty_close_btn'),
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.warmTaupeBrown,
              size: 22,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(StartKittyFlowState flowState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: <Widget>[
          _buildStepCircle(
            stepNumber: 1,
            title: 'Plan',
            isActive: flowState.currentStep == StartKittyStep.planCustomization,
            isCompleted: flowState.currentStep.index > 0,
          ),
          _buildStepDivider(isCompleted: flowState.currentStep.index > 0),
          _buildStepCircle(
            stepNumber: 2,
            title: 'Number',
            isActive: flowState.currentStep == StartKittyStep.numberSelection,
            isCompleted: flowState.currentStep.index > 1,
          ),
          _buildStepDivider(isCompleted: flowState.currentStep.index > 1),
          _buildStepCircle(
            stepNumber: 3,
            title: 'Confirm',
            isActive: flowState.currentStep == StartKittyStep.confirmation,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle({
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    final Color bgColor = isCompleted
        ? AppColors.primaryEmerald
        : isActive
            ? AppColors.deepEmeraldBase
            : AppColors.surfacePageBg;

    final Color textColor = isCompleted || isActive
        ? Colors.white
        : AppColors.warmTaupeBrown;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.goldPrimary : AppColors.warmLinenInset,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  stepNumber.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? AppColors.deepEmeraldBase : AppColors.warmTaupeBrown,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isCompleted ? AppColors.primaryEmerald : AppColors.warmLinenInset,
      ),
    );
  }

  // ==========================================
  // STEP 1: PLAN CUSTOMIZATION
  // ==========================================
  Widget _buildStep1PlanCustomization(
    BuildContext context,
    StartKittyFlowState flowState,
    StartKittyFlowController flowController,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        if (flowState.sourceGrams != null && flowState.sourceKarat != null) ...<Widget>[
          Container(
            key: const Key('start_kitty_calculation_context_banner'),
            margin: const EdgeInsets.only(bottom: AppSpacing.space12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: AppRadius.border10,
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.calculate_outlined, size: 16, color: Color(0xFF92400E)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Budget calculated from Gold Calculator (${flowState.sourceGrams!.toStringAsFixed(3)}g ${flowState.sourceKarat})',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Scheme Summary Pill Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfacePageBg,
            borderRadius: AppRadius.border16,
            border: Border.all(color: AppColors.warmLinenInset),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.champagneFoil,
                  borderRadius: AppRadius.border12,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.savings_rounded,
                  color: AppColors.deepEmeraldBase,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.scheme.name,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepEmeraldBase,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${flowState.durationMonths} Months Duration (${flowState.customerMonths}+${flowState.bonusMonths} Bonus Scheme)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warmTaupeBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Monthly Contribution Amount Selector
        const Text(
          'Select Monthly Contribution',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.deepEmeraldBase,
          ),
        ),
        const SizedBox(height: 10),

        // Quick Preset Pills
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _amountPresets.map((int amount) {
            final bool isSelected = flowState.monthlyAmount == amount;
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _amountInputController.text = amount.toString();
                flowController.setMonthlyAmount(amount);
              },
              borderRadius: AppRadius.border12,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.deepEmeraldBase : AppColors.surfacePageBg,
                  borderRadius: AppRadius.border12,
                  border: Border.all(
                    color: isSelected ? AppColors.goldPrimary : AppColors.warmLinenInset,
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Text(
                  CurrencyFormatter.formatRupees(amount),
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.deepEmeraldBase,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Custom Amount Input Field
        TextFormField(
          controller: _amountInputController,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Custom Monthly Amount (Min ₹1,000)',
            prefixText: '₹ ',
            prefixStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.deepEmeraldBase,
            ),
            filled: true,
            fillColor: AppColors.surfacePageBg,
            border: OutlineInputBorder(
              borderRadius: AppRadius.border12,
              borderSide: BorderSide(color: AppColors.warmLinenInset),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.border12,
              borderSide: BorderSide(color: AppColors.warmLinenInset),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.border12,
              borderSide: BorderSide(color: AppColors.goldPrimary, width: 1.5),
            ),
          ),
          onChanged: (String val) {
            final int? parsed = int.tryParse(val.trim());
            if (parsed != null) {
              flowController.setMonthlyAmount(parsed);
            }
          },
        ),
        const SizedBox(height: 20),

        // 11+1 Benefit Math Preview Card
        _build11Plus1MathPreview(flowState),
      ],
    );
  }

  Widget _build11Plus1MathPreview(StartKittyFlowState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfacePageBg,
        borderRadius: AppRadius.border16,
        border: Border.all(color: AppColors.warmLinenInset),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.goldPrimary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'YOUR 11+1 SAVINGS BENEFIT',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepEmeraldBase,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMathRow(
            label: 'You Pay (${state.customerMonths} Months)',
            value: CurrencyFormatter.formatRupees(state.customerTotal),
            isBold: false,
          ),
          const SizedBox(height: 8),
          _buildMathRow(
            label: 'Swastik Bonus (${state.bonusMonths} Month Free)',
            value: '+ ${CurrencyFormatter.formatRupees(state.bonusTotal)}',
            isBold: true,
            valueColor: AppColors.primaryEmerald,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.warmLinenInset),
          ),
          _buildMathRow(
            label: 'Total Value at Maturity',
            value: CurrencyFormatter.formatRupees(state.maturityValue),
            isBold: true,
            valueColor: AppColors.deepEmeraldBase,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMathRow({
    required String label,
    required String value,
    required bool isBold,
    Color? valueColor,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 13 : 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.warmTaupeBrown,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isLarge ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.deepEmeraldBase,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 2: KITTY NUMBER SELECTION MATRIX
  // ==========================================
  Widget _buildStep2NumberSelection(
    BuildContext context,
    StartKittyFlowState flowState,
    StartKittyFlowController flowController,
  ) {
    final KittyNumberPickerState pickerState =
        ref.watch(kittyNumberPickerControllerProvider);
    final KittyNumberPickerController pickerController =
        ref.read(kittyNumberPickerControllerProvider.notifier);

    return switch (pickerState.status) {
      KittyNumberPickerStatus.initial ||
      KittyNumberPickerStatus.loading =>
        const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrimary),
        ),
      KittyNumberPickerStatus.error => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: KittyErrorState(
              title: 'Unable to Load Kitty Numbers',
              message: pickerState.errorMessage ?? 'Please check connection.',
              retryLabel: 'Try Again',
              onRetry: pickerController.retry,
            ),
          ),
        ),
      KittyNumberPickerStatus.loaded => CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    KittySearchField(
                      controller: _slotSearchController,
                      hintText: 'Search lucky number (e.g. 7, 21, 51)...',
                      onChanged: pickerController.search,
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
                              color: AppColors.warmTaupeBrown,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          _buildPresetChip('No. 7', 7, pickerState, pickerController, flowController),
                          _buildPresetChip('No. 9', 9, pickerState, pickerController, flowController),
                          _buildPresetChip('No. 21', 21, pickerState, pickerController, flowController),
                          _buildPresetChip('No. 51', 51, pickerState, pickerController, flowController),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Legend
                    _buildLegendBar(pickerState),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            if (pickerState.filteredSlots.isEmpty)
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
                      final KittySlotEntity slot = pickerState.filteredSlots[index];
                      final bool isSelected =
                          flowState.selectedSlot?.number == slot.number ||
                          pickerState.selectedSlot?.number == slot.number;
                      return _buildSlotTile(
                        ctx,
                        slot,
                        isSelected,
                        pickerController,
                        flowController,
                      );
                    },
                    childCount: pickerState.filteredSlots.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space24),
            ),
          ],
        ),
    };
  }

  Widget _buildPresetChip(
    String label,
    int number,
    KittyNumberPickerState pickerState,
    KittyNumberPickerController pickerController,
    StartKittyFlowController flowController,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(
          color: AppColors.deepUmberBronze,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: AppColors.champagneFoil.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        side: const BorderSide(color: AppColors.warmLinenInset),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.border8),
        onPressed: () {
          _slotSearchController.text = number.toString();
          pickerController.search(number.toString());
          final bool ok = pickerController.selectLuckyNumber(number);
          if (ok) {
            try {
              final KittySlotEntity match = pickerState.slots.firstWhere(
                (KittySlotEntity s) => s.number == number,
              );
              flowController.selectSlot(match);
            } catch (_) {}
          }
        },
      ),
    );
  }

  Widget _buildLegendBar(KittyNumberPickerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfacePageBg,
        borderRadius: AppRadius.border8,
        border: Border.all(color: AppColors.warmLinenInset),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runAlignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 4,
        children: <Widget>[
          _buildLegendDot(
            color: AppColors.primaryEmerald,
            label: 'Available (${state.availableCount})',
          ),
          _buildLegendDot(
            color: AppColors.goldPrimary,
            label: 'Selected',
          ),
          _buildLegendDot(
            color: const Color(0xFF9E9E9E),
            label: 'Booked (${state.bookedCount})',
          ),
          if (state.lockedCount > 0)
            _buildLegendDot(
              color: AppColors.honeyGoldAccent,
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.warmTaupeBrown,
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
    KittyNumberPickerController pickerController,
    StartKittyFlowController flowController,
  ) {
    final String formattedNum = slot.number.toString().padLeft(2, '0');

    final Color bgColor = isSelected
        ? AppColors.deepEmeraldBase
        : slot.isBooked
            ? AppColors.surfacePageBg
            : slot.isLocked
                ? const Color(0xFFFFF9E6)
                : Colors.white;

    final Color borderColor = isSelected
        ? AppColors.goldPrimary
        : slot.isBooked
            ? AppColors.warmLinenInset
            : slot.isLocked
                ? AppColors.honeyGoldAccent
                : AppColors.primaryEmerald.withValues(alpha: 0.35);

    final Color textColor = isSelected
        ? Colors.white
        : slot.isBooked
            ? const Color(0xFF94A3B8)
            : slot.isLocked
                ? const Color(0xFFB45309)
                : AppColors.deepEmeraldBase;

    return Semantics(
      label: 'Kitty Number $formattedNum, ${slot.status.name}',
      button: slot.isAvailable,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (slot.isBooked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kitty Number #$formattedNum is already booked.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (slot.isLocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Kitty Number #$formattedNum is temporarily reserved in another checkout.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              HapticFeedback.selectionClick();
              pickerController.selectSlot(slot);
              flowController.selectSlot(slot);
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
            ),
            child: Center(
              child: Text(
                formattedNum,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STEP 3: CONFIRMATION & REVIEW
  // ==========================================
  Widget _buildStep3Confirmation(
    BuildContext context,
    StartKittyFlowState state,
    StartKittyFlowController flowController,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        // Review Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfacePageBg,
            borderRadius: AppRadius.border20,
            border: Border.all(color: AppColors.warmLinenInset),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0A063D2E),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header with Scheme Name & Number Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      state.scheme.name,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepEmeraldBase,
                      ),
                    ),
                  ),
                  if (state.selectedSlot != null)
                    KittyNumberPill(
                      number: state.selectedSlot!.tokenString,
                      isDarkSurface: false,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.warmLinenInset),
              const SizedBox(height: 14),

              // Detail rows
              _buildReviewRow(
                label: 'Monthly Contribution',
                value: '${CurrencyFormatter.formatRupees(state.monthlyAmount)} / month',
              ),
              const SizedBox(height: 10),
              _buildReviewRow(
                label: 'Scheme Duration',
                value: '${state.durationMonths} Months (${state.customerMonths} + ${state.bonusMonths} Bonus)',
              ),
              const SizedBox(height: 10),
              _buildReviewRow(
                label: 'Your Total Investment',
                value: CurrencyFormatter.formatRupees(state.customerTotal),
              ),
              const SizedBox(height: 10),
              _buildReviewRow(
                label: 'Swastik Bonus Contribution',
                value: '+ ${CurrencyFormatter.formatRupees(state.bonusTotal)}',
                valueColor: AppColors.primaryEmerald,
                isBold: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppColors.warmLinenInset),
              ),
              _buildReviewRow(
                label: 'Maturity Redemption Value',
                value: CurrencyFormatter.formatRupees(state.maturityValue),
                valueColor: AppColors.deepEmeraldBase,
                isBold: true,
                isLarge: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // First Month Payment Due Notice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: AppRadius.border12,
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.primaryEmerald,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'First Installment (Month 1)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepEmeraldBase,
                      ),
                    ),
                    Text(
                      'Pay ${CurrencyFormatter.formatRupees(state.monthlyAmount)} now to activate your Kitty and lock your number.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.warmTaupeBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Compliance & Trust Badge
        const Row(
          children: <Widget>[
            Icon(Icons.verified_user_rounded, color: AppColors.goldPrimary, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '100% BIS Hallmarked 916 Gold redemption. Zero hidden fees.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warmTaupeBrown,
                ),
              ),
            ),
          ],
        ),

        if (state.errorMessage != null) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            state.errorMessage!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 13 : 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.warmTaupeBrown,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isLarge ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.deepEmeraldBase,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STICKY BOTTOM BAR
  // ==========================================
  Widget _buildStickyBottomBar(
    BuildContext context,
    StartKittyFlowState flowState,
    StartKittyFlowController flowController,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCardBg,
        border: Border(
          top: BorderSide(color: AppColors.warmLinenInset, width: 1),
        ),
      ),
      child: switch (flowState.currentStep) {
        StartKittyStep.planCustomization => KittyPrimaryButton(
            label: 'CONTINUE TO NUMBER SELECTION →',
            isEnabled: flowState.canProceedStep1,
            height: 52,
            onPressed: flowController.nextStep,
          ),
        StartKittyStep.numberSelection => KittyPrimaryButton(
            label: flowState.selectedSlot != null
                ? 'REVIEW & CONFIRM (NUMBER ${flowState.selectedSlot!.number}) →'
                : 'SELECT A LUCKY NUMBER',
            isEnabled: flowState.canProceedStep2,
            height: 52,
            onPressed: flowController.nextStep,
          ),
        StartKittyStep.confirmation => KittyPrimaryButton(
            label: flowState.isSubmitting
                ? 'ENROLLING...'
                : 'PROCEED TO PAY MONTH 1 (${CurrencyFormatter.formatRupees(flowState.monthlyAmount)}) →',
            isEnabled: flowState.canProceedStep3,
            isLoading: flowState.isSubmitting,
            height: 52,
            onPressed: () async {
              final Map<String, dynamic>? result =
                  await flowController.submitEnrollment();
              if (result != null && context.mounted) {
                if (widget.onCompleted != null) {
                  widget.onCompleted!(result);
                }
                Navigator.of(context).pop();

                // Handoff to Checkout Screen
                final String membershipId =
                    result['membershipId'] as String? ?? 'MEM-NEW';
                final String tokenString =
                    result['tokenString'] as String? ?? '#SW-001';

                try {
                  unawaited(
                    context.push(
                      RoutePaths.checkout,
                      extra: CheckoutArgs(
                        membershipId: membershipId,
                        chitToken: tokenString,
                        monthFor: 1,
                        amount: flowState.monthlyAmount,
                      ),
                    ),
                  );
                } catch (_) {}
              }
            },
          ),
      },
    );
  }
}
