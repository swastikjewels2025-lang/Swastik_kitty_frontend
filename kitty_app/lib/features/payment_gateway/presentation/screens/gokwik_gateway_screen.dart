import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../checkout/domain/entities/payment_order_entity.dart';
import '../../domain/gateway_result.dart';

/// Sandboxed GoKwik Gateway Host Screen for Phase 11 simulation.
///
/// Presents order details received from backend payment initiation and allows
/// exercising all gateway outcomes (Completed, Declined, Cancelled, Pending)
/// to thoroughly test client-side polling and reconciliation logic.
class GokwikGatewayScreen extends ConsumerWidget {
  const GokwikGatewayScreen({
    super.key,
    this.order,
  });

  final PaymentOrderEntity? order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaymentOrderEntity activeOrder = order ??
        const PaymentOrderEntity(
          orderId: 'gokwik_ord_771829',
          paymentId: 'pay_662819',
          amount: 5000,
          currency: 'INR',
          merchantKey: 'mock_gokwik_mid_swastik',
        );

    final String formattedAmount = CurrencyFormatter.formatRupees(activeOrder.amount);

    return Scaffold(
      backgroundColor: AppColors.warmPearl,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const Key('gokwik_close_btn'),
          icon: const Icon(Icons.close_rounded, color: AppColors.deepForestCharcoal),
          onPressed: () {
            context.pop(const GatewayResult.cancelled(message: 'Payment dismissed by user.'));
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDE4),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.surfaceCardBorder,
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.primaryEmerald,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GoKwik Sandbox',
                    style: AppTypography.labelMeta(color: AppColors.primaryEmerald).copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Order Summary Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.space20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.border20,
                  border: Border.all(
                    color: AppColors.surfaceCardBorder,
                    width: 1,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      'SWASTIK JEWELLERS CHIT VAULT',
                      style: AppTypography.labelMeta(
                        color: AppColors.mutedSlateGray,
                      ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      formattedAmount,
                      key: const Key('gokwik_order_amount_text'),
                      style: AppTypography.amountDisplay(
                        color: AppColors.primaryEmerald,
                      ).copyWith(fontSize: 34),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    const Divider(color: AppColors.surfaceCardBorder),
                    const SizedBox(height: AppSpacing.space12),
                    _buildDetailRow('Gateway Order ID', activeOrder.orderId),
                    const SizedBox(height: 6),
                    _buildDetailRow('Payment Session', activeOrder.paymentId),
                    const SizedBox(height: 6),
                    _buildDetailRow('Currency', activeOrder.currency),
                    const SizedBox(height: 6),
                    _buildDetailRow('Environment', 'Sandbox / Mock Gateway'),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.space24),

              // Simulation Instruction Box
              Container(
                padding: const EdgeInsets.all(AppSpacing.space14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F5),
                  borderRadius: AppRadius.border12,
                  border: Border.all(
                    color: AppColors.surfaceCardBorder,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.mutedSlateGray,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.space10),
                    Expanded(
                      child: Text(
                        'Select a simulated customer action below to exercise gateway callbacks and backend reconciliation polling.',
                        style: AppTypography.bodySmall(
                          color: AppColors.mutedSlateGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.space24),

              // Action 1: Complete Payment (Primary Success)
              ElevatedButton(
                key: const Key('gokwik_simulate_success_btn'),
                onPressed: () async {
                  try {
                    final DioClient dio = ref.read(dioClientProvider);
                    await dio.post<Map<String, dynamic>>(
                      '/api/v1/payments/webhook',
                      data: <String, dynamic>{
                        'orderId': activeOrder.orderId,
                        'status': 'SUCCESS',
                        'transactionId': 'TXN-SW-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                      },
                      options: Options(headers: <String, dynamic>{
                        'x-gokwik-signature': 'test_signature',
                      }),
                    );
                  } catch (_) {}

                  if (context.mounted) {
                    context.pop(const GatewayResult.completed(
                      message: 'Simulated payment completed on GoKwik.',
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEmerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.border12,
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.check_circle_outline_rounded, size: 20),
                    const SizedBox(width: AppSpacing.space8),
                    Text(
                      'Simulate User Payment Complete',
                      style: AppTypography.bodyBold(
                        color: Colors.white,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.space12),

              // Action 2: Bank Decline
              OutlinedButton(
                key: const Key('gokwik_simulate_fail_btn'),
                onPressed: () async {
                  try {
                    final DioClient dio = ref.read(dioClientProvider);
                    await dio.post<Map<String, dynamic>>(
                      '/api/v1/payments/webhook',
                      data: <String, dynamic>{
                        'orderId': activeOrder.orderId,
                        'status': 'FAILED',
                      },
                      options: Options(headers: <String, dynamic>{
                        'x-gokwik-signature': 'test_signature',
                      }),
                    );
                  } catch (_) {}

                  if (context.mounted) {
                    context.pop(const GatewayResult.failed(
                      message: 'Bank declined transaction (insufficient funds or authorization timeout).',
                    ));
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(
                    color: Color(0xFFEF4444),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.space14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.border12,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.cancel_outlined, size: 18),
                    const SizedBox(width: AppSpacing.space8),
                    Text(
                      'Simulate Bank Decline (Failed)',
                      style: AppTypography.bodyBold(
                        color: const Color(0xFFDC2626),
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.space12),

              // Action 3: Cancelled by user
              OutlinedButton(
                key: const Key('gokwik_simulate_cancel_btn'),
                onPressed: () {
                  context.pop(const GatewayResult.cancelled(
                    message: 'Payment cancelled by patron.',
                  ));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deepForestCharcoal,
                  side: const BorderSide(
                    color: AppColors.surfaceCardBorder,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.space14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.border12,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.arrow_back_rounded, size: 18),
                    const SizedBox(width: AppSpacing.space8),
                    Text(
                      'Cancel Payment & Dismiss',
                      style: AppTypography.bodyRegular(
                        color: AppColors.deepForestCharcoal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.space12),

              // Action 4: Return with Pending status
              TextButton(
                key: const Key('gokwik_simulate_pending_btn'),
                onPressed: () {
                  context.pop(const GatewayResult.pending(
                    message: 'Transaction pending webhook confirmation.',
                  ));
                },
                child: Text(
                  'Return Without Completion (Pending Verification)',
                  style: AppTypography.labelMeta(
                    color: AppColors.mutedSlateGray,
                  ).copyWith(decoration: TextDecoration.underline),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: AppTypography.labelMeta(color: AppColors.mutedSlateGray),
        ),
        Text(
          value,
          style: AppTypography.labelMeta(color: AppColors.deepForestCharcoal).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
