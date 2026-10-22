import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/receipt_entity.dart';

/// Digital Tax & Gold Passbook Receipt Modal View (Phase 13).
///
/// Faithfully reproduces the approved parchment invoice design from `D:\ui design\passbook.html`
/// and `.receipt-paper` from `D:\ui design\dashboard.css`.
class DigitalReceiptModal extends StatelessWidget {
  const DigitalReceiptModal({
    super.key,
    required this.receipt,
    required this.isGenerating,
    required this.isOpeningPdf,
    required this.onOpenPdf,
    required this.onRefresh,
    required this.onClose,
  });

  final ReceiptEntity receipt;
  final bool isGenerating;
  final bool isOpeningPdf;
  final VoidCallback onOpenPdf;
  final VoidCallback onRefresh;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        color: AppColors.primaryEmerald,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.goldBorder.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 48,
            offset: Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header Row with Title and Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Official Gold Scheme Receipt',
                      key: const Key('receipt_modal_title'),
                      style: AppTypography.cardTitle(
                        color: Colors.white,
                      ).copyWith(fontSize: 19, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Swastik Jewellers Tax & Gold Passbook Invoice',
                      key: const Key('receipt_modal_subtitle'),
                      style: AppTypography.bodySmall(
                        color: AppColors.goldLight,
                      ).copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('receipt_close_btn'),
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space14),

          // Luxury Parchment Receipt Paper Container (.receipt-paper)
          Container(
            key: const Key('receipt_paper_card'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DECF), width: 1.2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 1. Top Bar: Transaction ID & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            receipt.transactionId,
                            key: const Key('receipt_txn_id'),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              color: Color(0xFF047857),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Receipt for Month ${receipt.installmentNumber}',
                            key: const Key('receipt_installment_label'),
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF556B62),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      key: const Key('receipt_status_badge'),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F7F0),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFBBE5D4), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF047857)),
                          SizedBox(width: 4),
                          Text(
                            'PAYMENT CONFIRMED',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Dashed Line Divider
                const CustomPaint(
                  size: Size(double.infinity, 1),
                  painter: _DashedLinePainter(color: Color(0xFFD6CEC0)),
                ),

                const SizedBox(height: 10),

                // 2. Section: Scheme & Patron Details
                _buildReceiptRow('Chit Token Number:', '#SW-042', isHighlight: true),
                _buildReceiptRow('Scheme Name:', receipt.schemeName, allowWrap: true),
                _buildReceiptRow('Customer Name:', receipt.customerName),

                const SizedBox(height: 6),

                // 3. Section: 24K Gold Allocation Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF6EB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8DCC2), width: 0.9),
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildReceiptRow(
                        '24K Gold Allocated:',
                        '+${receipt.goldWeightCreditedGrams.toStringAsFixed(3)} grams',
                        valueColor: const Color(0xFFB45309), // Warm gold amber
                        isBold: true,
                        fontSize: 12.0,
                      ),
                      _buildReceiptRow(
                        'Gold Benchmark Rate:',
                        '₹${receipt.goldRateAtPayment.toStringAsFixed(2)} / g',
                        fontSize: 11.0,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // 4. Section: Statutory GST & Payment Info
                _buildReceiptRow(
                  'Statutory GST (3% Bullion):',
                  '₹0.00 (Covered by Jeweler)',
                  valueColor: const Color(0xFF047857),
                  isBold: true,
                  allowWrap: true,
                ),
                _buildReceiptRow('Payment Mode:', _formatPaymentMethod(receipt)),
                _buildReceiptRow('Payment Date:', _formatDate(receipt.paidAt)),

                const SizedBox(height: 6),

                // 5. Total Amount Paid Row
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFD6CEC0), width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'Total Amount Paid:',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepForestCharcoal,
                          ),
                        ),
                      ),
                      Text(
                        '${CurrencyFormatter.formatRupees(receipt.amount)}.00',
                        key: const Key('receipt_total_amount'),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepForestCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 6. BIS 999 Hallmark Disclaimer Footnote
                const Text(
                  'This is an official digital passbook receipt issued by Swastik Jewellers Pvt Ltd. '
                  'All accumulated gold is physically backed and audited under BIS 999 Hallmark certification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 9.5,
                    height: 1.35,
                    color: Color(0xFF7A8B83),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space14),

          // Async Receipt Generation Notice (if receiptUrl == null)
          if (isGenerating)
            Container(
              key: const Key('receipt_generating_banner'),
              margin: const EdgeInsets.only(bottom: AppSpacing.space12),
              padding: const EdgeInsets.all(AppSpacing.space12),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.goldBorder.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Generating Official Tax PDF...',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFE28A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Receipt is being generated. Your PDF invoice is being signed and uploaded. Tap check status to refresh.',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    key: const Key('btn_receipt_refresh'),
                    onPressed: onRefresh,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.goldPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Refresh',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Action Buttons: View/Download PDF & Done
          Row(
            children: <Widget>[
              Expanded(
                child: isGenerating
                    ? OutlinedButton.icon(
                        key: const Key('btn_view_receipt_pdf_disabled'),
                        onPressed: onRefresh,
                        icon: const Icon(Icons.sync_rounded, size: 16),
                        label: const Text('Check Status'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.goldPrimary,
                          side: const BorderSide(color: Color(0xFF4A4027)),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    : ElevatedButton.icon(
                        key: const Key('btn_view_receipt_pdf'),
                        onPressed: isOpeningPdf ? null : onOpenPdf,
                        icon: isOpeningPdf
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.picture_as_pdf_outlined, size: 16),
                        label: Text(isOpeningPdf ? 'Opening...' : 'View / Download PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF047857),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: ElevatedButton(
                  key: const Key('btn_receipt_done'),
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFECC97D),
                    foregroundColor: AppColors.deepForestCharcoal,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
    bool isHighlight = false,
    double fontSize = 11.5,
    bool allowWrap = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: allowWrap ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: fontSize,
              color: const Color(0xFF556B62),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: allowWrap,
              maxLines: allowWrap ? 2 : 1,
              overflow: allowWrap ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: fontSize,
                fontWeight: isBold || isHighlight ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ??
                    (isHighlight ? const Color(0xFF047857) : AppColors.deepForestCharcoal),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return 'Today';
    }
  }

  String _formatPaymentMethod(ReceiptEntity receipt) {
    final String raw = receipt.paymentMethod.name.toUpperCase();
    if (raw == 'ONLINE') return 'UPI / NetBanking';
    return raw;
  }
}

/// Custom painter for dashed dividers matching web design.
class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const double dashWidth = 5;
    const double dashSpace = 4;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
