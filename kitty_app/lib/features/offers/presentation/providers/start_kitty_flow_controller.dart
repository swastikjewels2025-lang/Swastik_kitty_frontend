import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/repositories/mock_scheme_repository.dart';
import '../../domain/entities/kitty_slot_entity.dart';
import '../../domain/entities/scheme_entity.dart';
import '../../domain/repositories/i_scheme_repository.dart';
import 'start_kitty_flow_state.dart';

/// Provider for managing multi-step guided start kitty enrollment flow.
final NotifierProvider<StartKittyFlowController, StartKittyFlowState>
    startKittyFlowControllerProvider =
    NotifierProvider<StartKittyFlowController, StartKittyFlowState>(
  StartKittyFlowController.new,
);

class StartKittyFlowController extends Notifier<StartKittyFlowState> {
  late ISchemeRepository _repository;

  @override
  StartKittyFlowState build() {
    _repository = ref.watch(schemeRepositoryProvider);
    return StartKittyFlowState(
      scheme: MockSchemeRepository.prototypeSchemes.first,
    );
  }

  void init(
    SchemeEntity scheme, {
    int? customMonthlyAmount,
    double? sourceGrams,
    String? sourceKarat,
  }) {
    state = StartKittyFlowState(
      scheme: scheme,
      monthlyAmount: customMonthlyAmount ?? scheme.monthlyInstallment,
      durationMonths: scheme.durationMonths,
      sourceGrams: sourceGrams,
      sourceKarat: sourceKarat,
    );
  }

  void setMonthlyAmount(int amount) {
    state = state.copyWith(monthlyAmount: amount, clearError: true);
  }

  void setDuration(int months) {
    state = state.copyWith(durationMonths: months);
  }

  void selectSlot(KittySlotEntity slot) {
    if (slot.isAvailable) {
      state = state.copyWith(selectedSlot: slot, clearError: true);
    }
  }

  void clearSlot() {
    state = state.copyWith(clearSelectedSlot: true);
  }

  void nextStep() {
    state = state.copyWith(clearError: true);
    switch (state.currentStep) {
      case StartKittyStep.planCustomization:
        if (state.canProceedStep1) {
          state = state.copyWith(currentStep: StartKittyStep.numberSelection);
        }
        break;
      case StartKittyStep.numberSelection:
        if (state.canProceedStep2) {
          state = state.copyWith(currentStep: StartKittyStep.confirmation);
        }
        break;
      case StartKittyStep.confirmation:
        break;
    }
  }

  void previousStep() {
    state = state.copyWith(clearError: true);
    switch (state.currentStep) {
      case StartKittyStep.planCustomization:
        break;
      case StartKittyStep.numberSelection:
        state = state.copyWith(currentStep: StartKittyStep.planCustomization);
        break;
      case StartKittyStep.confirmation:
        state = state.copyWith(currentStep: StartKittyStep.numberSelection);
        break;
    }
  }

  void goToStep(StartKittyStep step) {
    state = state.copyWith(currentStep: step, clearError: true);
  }

  Future<Map<String, dynamic>?> submitEnrollment() async {
    if (state.selectedSlot == null) {
      state = state.copyWith(errorMessage: 'Please select a Kitty Number first.');
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final Map<String, dynamic> result = await _repository.enrollScheme(
        schemeId: state.scheme.id,
        monthlyAmount: state.monthlyAmount,
        slotNumber: state.selectedSlot!.number,
      );

      state = state.copyWith(
        isSubmitting: false,
        enrollmentResult: result,
      );
      return result;
    } on AppException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.message,
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Enrollment registration failed. Please try again.',
      );
      return null;
    }
  }
}
