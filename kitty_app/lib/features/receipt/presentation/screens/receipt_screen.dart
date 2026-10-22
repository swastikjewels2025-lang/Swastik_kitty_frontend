import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../shared/widgets/feedback/kitty_error_state.dart';
import '../../../../shared/widgets/feedback/kitty_shimmer.dart';
import '../../../../shared/widgets/feedback/kitty_skeleton.dart';
import '../../../passbook/domain/entities/passbook_entry_entity.dart';
import '../../domain/entities/receipt_entity.dart';
import '../providers/receipt_controller.dart';
import '../providers/receipt_state.dart';
import '../widgets/digital_receipt_modal.dart';

/// Screen for viewing official digital tax & passbook receipt (Phase 13).
class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({
    super.key,
    required this.receiptId,
    this.passbookEntry,
    this.receipt,
  });

  final String receiptId;
  final PassbookEntryEntity? passbookEntry;
  final ReceiptEntity? receipt;

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(receiptControllerProvider.notifier).initialize(
            receiptId: widget.receiptId,
            initialPassbookEntry: widget.passbookEntry,
            initialReceipt: widget.receipt,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ReceiptState state = ref.watch(receiptControllerProvider);
    final ReceiptController controller =
        ref.read(receiptControllerProvider.notifier);

    // Listen for error messages while attempting to open PDF
    ref.listen<ReceiptState>(receiptControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.status != ReceiptStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.statusErrorText,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    void handleClose() {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        try {
          context.go(RoutePaths.passbook);
        } catch (_) {
          // Fallback when rendered outside GoRouter in isolated widget tests
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xCC000000), // Semi-transparent modal backdrop scrim
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space24,
            ),
            child: _buildContent(context, state, controller, handleClose),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ReceiptState state,
    ReceiptController controller,
    VoidCallback onClose,
  ) {
    if (state.isLoading) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(AppSpacing.space24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceCardBorder),
        ),
        child: const KittyShimmer(
          isDarkSurface: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              KittySkeletonBox(
                width: 180,
                height: 24,
                borderRadius: AppRadius.border10,
                isDarkSurface: false,
              ),
              SizedBox(height: 16),
              KittySkeletonBox(
                width: double.infinity,
                height: 280,
                borderRadius: AppRadius.border14,
                isDarkSurface: false,
              ),
              SizedBox(height: 16),
              KittySkeletonBox(
                width: double.infinity,
                height: 48,
                borderRadius: AppRadius.border10,
                isDarkSurface: false,
              ),
            ],
          ),
        ),
      );
    }

    if (state.hasError) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(AppSpacing.space24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceCardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            KittyErrorState(
              title: 'Receipt Unavailable',
              message: state.errorMessage ?? 'Unable to load payment receipt.',
              onRetry: () => controller.loadReceipt(widget.receiptId),
              retryLabel: 'Retry Load',
              isDarkSurface: false,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onClose,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryEmerald,
                side: const BorderSide(color: AppColors.surfaceCardBorder),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    final ReceiptEntity? activeReceipt = state.receipt;
    if (activeReceipt == null) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(AppSpacing.space24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceCardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'No Receipt Record Found',
              style: TextStyle(color: AppColors.deepForestCharcoal, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to Passbook'),
            ),
          ],
        ),
      );
    }

    return DigitalReceiptModal(
      receipt: activeReceipt,
      isGenerating: state.isGenerating,
      isOpeningPdf: state.isOpeningPdf,
      onOpenPdf: controller.openPdf,
      onRefresh: controller.refreshReceipt,
      onClose: onClose,
    );
  }
}
