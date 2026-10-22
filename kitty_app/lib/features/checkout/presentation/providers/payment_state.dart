import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/payment_order_entity.dart';

/// Presentation state lifecycle for payment flow and polling.
enum PaymentUiStatus {
  /// Initial idle state. Ready for method selection and initiation.
  initial,

  /// Calling initiatePayment to acquire GoKwik orderId and session.
  initiating,

  /// Gateway UI currently active on screen.
  awaitingGateway,

  /// Polling backend /api/v1/payments/status/:orderId for reconciliation.
  polling,

  /// Backend confirmed payment success. Terminal state.
  success,

  /// Backend confirmed payment failed. Terminal state.
  failed,

  /// Payment cancelled by user. Terminal state.
  cancelled,

  /// Polling reached maximum attempts (timeout) without final confirmation.
  timeout,

  /// Error occurred during initiation or polling.
  error,
}

/// Granular payment channels available to patrons.
enum PaymentChannel {
  /// Instant Unified Payments Interface (GPay, PhonePe, Paytm, BHIM).
  upi,

  /// Direct internet banking across 40+ partnered Indian banks.
  netbanking,

  /// Major debit and credit card networks (Visa, Mastercard, RuPay).
  card,

  /// Doorstep cash collection by an authorized Swastik logistics executive.
  pickCash;

  String get displayName {
    switch (this) {
      case PaymentChannel.upi:
        return 'Instant UPI';
      case PaymentChannel.netbanking:
        return 'Net Banking';
      case PaymentChannel.card:
        return 'Debit / Credit Card';
      case PaymentChannel.pickCash:
        return 'Pick Cash';
    }
  }

  PaymentMethodEnum get methodEnum {
    switch (this) {
      case PaymentChannel.pickCash:
        return PaymentMethodEnum.cash;
      case PaymentChannel.upi:
      case PaymentChannel.netbanking:
      case PaymentChannel.card:
        return PaymentMethodEnum.online;
    }
  }
}

/// Comprehensive immutable state container for Payment Checkout and Polling.
class PaymentState {
  const PaymentState({
    this.status = PaymentUiStatus.initial,
    this.membershipId = 'mem_994411',
    this.chitToken = '#SW-042',
    this.monthFor = 9,
    this.amount = 5000, // Whole integer Rupees
    this.monthlyInstallment = 5000,
    this.selectedMonthsCount = 1,
    this.totalDurationMonths = 12,
    this.startMonth = 9,
    this.remainingMonthsCount = 4,
    this.selectedChannel = PaymentChannel.upi,
    PaymentMethodEnum? selectedMethod,
    this.order,
    this.statusEntity,
    this.pollCount = 0,
    this.maxPolls = 5,
    this.pollingMessage = 'Verifying payment with bank...',
    this.errorMessage,
  })  : selectedMethod = selectedMethod ??
            (selectedChannel == PaymentChannel.pickCash
                ? PaymentMethodEnum.cash
                : PaymentMethodEnum.online);

  final PaymentUiStatus status;
  final String membershipId;
  final String chitToken;
  final int monthFor;
  final int amount; // Whole integer Rupees
  final int monthlyInstallment;
  final int selectedMonthsCount;
  final int totalDurationMonths;
  final int startMonth;
  final int remainingMonthsCount;
  final PaymentChannel selectedChannel;
  final PaymentMethodEnum selectedMethod;
  final PaymentOrderEntity? order;
  final PaymentStatusEntity? statusEntity;
  final int pollCount;
  final int maxPolls;
  final String pollingMessage;
  final String? errorMessage;

  /// List of sequential month numbers covered by the current selection.
  List<int> get selectedMonthsList =>
      List<int>.generate(selectedMonthsCount, (int i) => startMonth + i);

  /// Dynamically calculated total payable rupees.
  int get totalPayable => selectedMonthsCount * monthlyInstallment;

  /// True if payment is initiating, in gateway, or currently polling.
  bool get isBusy =>
      status == PaymentUiStatus.initiating ||
      status == PaymentUiStatus.awaitingGateway ||
      status == PaymentUiStatus.polling;

  /// True if payment can be initiated (idle or after terminal failure/retry).
  bool get canInitiate =>
      status == PaymentUiStatus.initial ||
      status == PaymentUiStatus.failed ||
      status == PaymentUiStatus.cancelled ||
      status == PaymentUiStatus.error;

  /// True if in terminal state.
  bool get isTerminal =>
      status == PaymentUiStatus.success ||
      status == PaymentUiStatus.failed ||
      status == PaymentUiStatus.cancelled ||
      status == PaymentUiStatus.timeout;

  bool get isInitial => status == PaymentUiStatus.initial;
  bool get isInitiating => status == PaymentUiStatus.initiating;
  bool get isAwaitingGateway => status == PaymentUiStatus.awaitingGateway;
  bool get isPolling => status == PaymentUiStatus.polling;
  bool get isSuccess => status == PaymentUiStatus.success;
  bool get isFailed => status == PaymentUiStatus.failed;
  bool get isCancelled => status == PaymentUiStatus.cancelled;
  bool get isTimeout => status == PaymentUiStatus.timeout;
  bool get isError => status == PaymentUiStatus.error;

  PaymentState copyWith({
    PaymentUiStatus? status,
    String? membershipId,
    String? chitToken,
    int? monthFor,
    int? amount,
    int? monthlyInstallment,
    int? selectedMonthsCount,
    int? totalDurationMonths,
    int? startMonth,
    int? remainingMonthsCount,
    PaymentChannel? selectedChannel,
    PaymentMethodEnum? selectedMethod,
    PaymentOrderEntity? order,
    PaymentStatusEntity? statusEntity,
    int? pollCount,
    int? maxPolls,
    String? pollingMessage,
    String? errorMessage,
    bool clearError = false,
  }) {
    final PaymentChannel effectiveChannel = selectedChannel ?? this.selectedChannel;
    final PaymentMethodEnum effectiveMethod = selectedMethod ??
        (selectedChannel != null ? selectedChannel.methodEnum : this.selectedMethod);

    return PaymentState(
      status: status ?? this.status,
      membershipId: membershipId ?? this.membershipId,
      chitToken: chitToken ?? this.chitToken,
      monthFor: monthFor ?? this.monthFor,
      amount: amount ?? this.amount,
      monthlyInstallment: monthlyInstallment ?? this.monthlyInstallment,
      selectedMonthsCount: selectedMonthsCount ?? this.selectedMonthsCount,
      totalDurationMonths: totalDurationMonths ?? this.totalDurationMonths,
      startMonth: startMonth ?? this.startMonth,
      remainingMonthsCount: remainingMonthsCount ?? this.remainingMonthsCount,
      selectedChannel: effectiveChannel,
      selectedMethod: effectiveMethod,
      order: order ?? this.order,
      statusEntity: statusEntity ?? this.statusEntity,
      pollCount: pollCount ?? this.pollCount,
      maxPolls: maxPolls ?? this.maxPolls,
      pollingMessage: pollingMessage ?? this.pollingMessage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
