import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/notification_entity.dart';

/// Helper factory for generating safe local notification entries from app milestone events.
abstract final class NotificationEventHelper {
  /// Local notification for a successful monthly installment payment.
  static NotificationEntity createPaymentSuccessNotification({
    required double amount,
    required double goldGrams,
    required int monthNumber,
    String? transactionId,
  }) {
    final String nowId = DateTime.now().millisecondsSinceEpoch.toString();
    return NotificationEntity(
      id: 'local_pay_$nowId',
      title: 'Month $monthNumber Installment Verified 🎉',
      message: '₹${amount.toStringAsFixed(0)} deposited. +${goldGrams.toStringAsFixed(3)}g 24K gold credited to your vault.',
      type: NotificationTypeEnum.transaction,
      isRead: false,
      createdAt: DateTime.now().toUtc(),
      actionUrl: '/passbook',
      metadata: <String, dynamic>{
        'transactionId': transactionId ?? 'TXN-SW-LOCAL-$nowId',
        'month': monthNumber,
        'amount': amount,
        'goldGrams': goldGrams,
      },
    );
  }

  /// Local notification for KYC submission.
  static NotificationEntity createKycSubmittedNotification() {
    final String nowId = DateTime.now().millisecondsSinceEpoch.toString();
    return NotificationEntity(
      id: 'local_kyc_$nowId',
      title: 'KYC Verification In Progress ⏳',
      message: 'Your government identity documents have been received. Verification takes less than 24 hours.',
      type: NotificationTypeEnum.system,
      isRead: false,
      createdAt: DateTime.now().toUtc(),
      actionUrl: '/kyc',
    );
  }

  /// Local notification for scheme enrollment.
  static NotificationEntity createSchemeEnrolledNotification({
    required String schemeName,
    required double monthlyInstallment,
  }) {
    final String nowId = DateTime.now().millisecondsSinceEpoch.toString();
    return NotificationEntity(
      id: 'local_sch_$nowId',
      title: 'Welcome to $schemeName ✨',
      message: 'Your monthly gold savings journey has begun with ₹${monthlyInstallment.toStringAsFixed(0)}/month.',
      type: NotificationTypeEnum.scheme,
      isRead: false,
      createdAt: DateTime.now().toUtc(),
      actionUrl: '/dashboard',
    );
  }
}
