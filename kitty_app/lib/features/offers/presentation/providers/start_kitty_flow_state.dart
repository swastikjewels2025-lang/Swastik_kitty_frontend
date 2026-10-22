import 'package:flutter/foundation.dart';
import '../../domain/entities/kitty_slot_entity.dart';
import '../../domain/entities/scheme_entity.dart';

/// The 3 steps of the Guided Start Kitty enrollment flow.
enum StartKittyStep {
  planCustomization,
  numberSelection,
  confirmation,
}

@immutable
class StartKittyFlowState {
  const StartKittyFlowState({
    required this.scheme,
    this.currentStep = StartKittyStep.planCustomization,
    this.monthlyAmount = 5000,
    this.durationMonths = 12,
    this.selectedSlot,
    this.sourceGrams,
    this.sourceKarat,
    this.isSubmitting = false,
    this.errorMessage,
    this.enrollmentResult,
  });

  final SchemeEntity scheme;
  final StartKittyStep currentStep;
  final int monthlyAmount;
  final int durationMonths;
  final KittySlotEntity? selectedSlot;
  final double? sourceGrams;
  final String? sourceKarat;
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, dynamic>? enrollmentResult;

  int get customerMonths {
    if (durationMonths == 12) return 11;
    if (durationMonths == 18) return 16;
    return (durationMonths - 1).clamp(1, durationMonths);
  }

  int get bonusMonths => durationMonths - customerMonths;
  int get customerTotal => customerMonths * monthlyAmount;
  int get bonusTotal => bonusMonths * monthlyAmount;
  int get maturityValue => customerTotal + bonusTotal;

  bool get canProceedStep1 => monthlyAmount >= 1000;
  bool get canProceedStep2 => selectedSlot != null && selectedSlot!.isAvailable;
  bool get canProceedStep3 => !isSubmitting && selectedSlot != null;

  StartKittyFlowState copyWith({
    SchemeEntity? scheme,
    StartKittyStep? currentStep,
    int? monthlyAmount,
    int? durationMonths,
    KittySlotEntity? selectedSlot,
    double? sourceGrams,
    String? sourceKarat,
    bool clearSelectedSlot = false,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    Map<String, dynamic>? enrollmentResult,
  }) {
    return StartKittyFlowState(
      scheme: scheme ?? this.scheme,
      currentStep: currentStep ?? this.currentStep,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      durationMonths: durationMonths ?? this.durationMonths,
      selectedSlot: clearSelectedSlot ? null : (selectedSlot ?? this.selectedSlot),
      sourceGrams: sourceGrams ?? this.sourceGrams,
      sourceKarat: sourceKarat ?? this.sourceKarat,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      enrollmentResult: enrollmentResult ?? this.enrollmentResult,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StartKittyFlowState &&
        other.scheme == scheme &&
        other.currentStep == currentStep &&
        other.monthlyAmount == monthlyAmount &&
        other.durationMonths == durationMonths &&
        other.selectedSlot == selectedSlot &&
        other.isSubmitting == isSubmitting &&
        other.errorMessage == errorMessage &&
        other.enrollmentResult == enrollmentResult;
  }

  @override
  int get hashCode => Object.hash(
        scheme,
        currentStep,
        monthlyAmount,
        durationMonths,
        selectedSlot,
        isSubmitting,
        errorMessage,
        enrollmentResult,
      );
}
