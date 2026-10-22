/// Centralized enumerations and status flags for Kitty App.
///
/// Implements defensive deserialization with `.unknown` fallbacks
/// to ensure the frontend never throws an unhandled exception when
/// the backend introduces future enum values.
library;

/// Installment status of a monthly passbook record.
enum InstallmentStatusEnum {
  paid,
  current,
  upcoming,
  bonus,
  preJoin,
  defaulted,
  unknown;

  static InstallmentStatusEnum fromString(String? value) {
    if (value == null || value.trim().isEmpty) return InstallmentStatusEnum.unknown;
    final String clean = value.trim().toUpperCase();
    switch (clean) {
      case 'PAID':
        return InstallmentStatusEnum.paid;
      case 'CURRENT':
        return InstallmentStatusEnum.current;
      case 'UPCOMING':
        return InstallmentStatusEnum.upcoming;
      case 'BONUS':
        return InstallmentStatusEnum.bonus;
      case 'PRE_JOIN':
      case 'PREJOIN':
        return InstallmentStatusEnum.preJoin;
      case 'DEFAULTED':
        return InstallmentStatusEnum.defaulted;
      default:
        return InstallmentStatusEnum.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case InstallmentStatusEnum.paid:
        return 'PAID';
      case InstallmentStatusEnum.current:
        return 'CURRENT';
      case InstallmentStatusEnum.upcoming:
        return 'UPCOMING';
      case InstallmentStatusEnum.bonus:
        return 'BONUS';
      case InstallmentStatusEnum.preJoin:
        return 'PRE_JOIN';
      case InstallmentStatusEnum.defaulted:
        return 'DEFAULTED';
      case InstallmentStatusEnum.unknown:
        return 'UNKNOWN';
    }
  }
}

/// Membership status of an enrolled user scheme.
enum MembershipStatusEnum {
  active,
  preJoin,
  winner,
  completed,
  defaulted,
  unknown;

  static MembershipStatusEnum fromString(String? value) {
    if (value == null || value.trim().isEmpty) return MembershipStatusEnum.unknown;
    final String clean = value.trim().toUpperCase();
    switch (clean) {
      case 'ACTIVE':
        return MembershipStatusEnum.active;
      case 'PRE_JOIN':
      case 'PREJOIN':
        return MembershipStatusEnum.preJoin;
      case 'WINNER':
        return MembershipStatusEnum.winner;
      case 'COMPLETED':
        return MembershipStatusEnum.completed;
      case 'DEFAULTED':
        return MembershipStatusEnum.defaulted;
      default:
        return MembershipStatusEnum.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case MembershipStatusEnum.active:
        return 'ACTIVE';
      case MembershipStatusEnum.preJoin:
        return 'PRE_JOIN';
      case MembershipStatusEnum.winner:
        return 'WINNER';
      case MembershipStatusEnum.completed:
        return 'COMPLETED';
      case MembershipStatusEnum.defaulted:
        return 'DEFAULTED';
      case MembershipStatusEnum.unknown:
        return 'UNKNOWN';
    }
  }
}

/// Statutory KYC compliance status.
enum KycStatusEnum {
  notSubmitted,
  pending,
  verified,
  rejected,
  unknown;

  static KycStatusEnum fromString(String? value) {
    if (value == null || value.trim().isEmpty) return KycStatusEnum.unknown;
    final String clean = value.trim().toUpperCase();
    switch (clean) {
      case 'NOT_SUBMITTED':
      case 'NOTSUBMITTED':
        return KycStatusEnum.notSubmitted;
      case 'PENDING':
        return KycStatusEnum.pending;
      case 'VERIFIED':
        return KycStatusEnum.verified;
      case 'REJECTED':
        return KycStatusEnum.rejected;
      default:
        return KycStatusEnum.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case KycStatusEnum.notSubmitted:
        return 'NOT_SUBMITTED';
      case KycStatusEnum.pending:
        return 'PENDING';
      case KycStatusEnum.verified:
        return 'VERIFIED';
      case KycStatusEnum.rejected:
        return 'REJECTED';
      case KycStatusEnum.unknown:
        return 'UNKNOWN';
    }
  }
}

/// KYC statutory document types.
enum DocTypeEnum {
  aadhaar,
  pan,
  unknown;

  static DocTypeEnum fromString(String? value) {
    if (value == null || value.trim().isEmpty) return DocTypeEnum.unknown;
    final String clean = value.trim().toUpperCase();
    switch (clean) {
      case 'AADHAAR':
        return DocTypeEnum.aadhaar;
      case 'PAN':
        return DocTypeEnum.pan;
      default:
        return DocTypeEnum.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DocTypeEnum.aadhaar:
        return 'AADHAAR';
      case DocTypeEnum.pan:
        return 'PAN';
      case DocTypeEnum.unknown:
        return 'UNKNOWN';
    }
  }
}

/// Payment channel method.
enum PaymentMethodEnum {
  online,
  cash,
  unknown;

  static PaymentMethodEnum fromString(String? value) {
    if (value == null || value.trim().isEmpty) return PaymentMethodEnum.unknown;
    final String clean = value.trim().toUpperCase();
    switch (clean) {
      case 'ONLINE':
      case 'UPI':
        return PaymentMethodEnum.online;
      case 'CASH':
        return PaymentMethodEnum.cash;
      default:
        return PaymentMethodEnum.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case PaymentMethodEnum.online:
        return 'ONLINE';
      case PaymentMethodEnum.cash:
        return 'CASH';
      case PaymentMethodEnum.unknown:
        return 'UNKNOWN';
    }
  }
}

/// Transactional payment lifecycle status.
enum PaymentStatusEnum {
  pending,
  success,
  failed,
  cancelled,
  unknown;

  static PaymentStatusEnum fromString(String? value) {
    if (value == null || value.trim().isEmpty) return PaymentStatusEnum.unknown;
    final String clean = value.trim().toUpperCase();
    switch (clean) {
      case 'PENDING':
        return PaymentStatusEnum.pending;
      case 'SUCCESS':
        return PaymentStatusEnum.success;
      case 'FAILED':
        return PaymentStatusEnum.failed;
      case 'CANCELLED':
        return PaymentStatusEnum.cancelled;
      default:
        return PaymentStatusEnum.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case PaymentStatusEnum.pending:
        return 'PENDING';
      case PaymentStatusEnum.success:
        return 'SUCCESS';
      case PaymentStatusEnum.failed:
        return 'FAILED';
      case PaymentStatusEnum.cancelled:
        return 'CANCELLED';
      case PaymentStatusEnum.unknown:
        return 'UNKNOWN';
    }
  }
}

/// Availability state of a gold kitty savings scheme.
enum SchemeStatusEnum {
  open,
  ongoing,
  completed,
  unknown;

  static SchemeStatusEnum fromString(String? value) {
    if (value == null || value.trim().isEmpty) return SchemeStatusEnum.unknown;
    final String clean = value.trim().toUpperCase();
    switch (clean) {
      case 'OPEN':
        return SchemeStatusEnum.open;
      case 'ONGOING':
        return SchemeStatusEnum.ongoing;
      case 'COMPLETED':
        return SchemeStatusEnum.completed;
      default:
        return SchemeStatusEnum.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case SchemeStatusEnum.open:
        return 'OPEN';
      case SchemeStatusEnum.ongoing:
        return 'ONGOING';
      case SchemeStatusEnum.completed:
        return 'COMPLETED';
      case SchemeStatusEnum.unknown:
        return 'UNKNOWN';
    }
  }
}

/// User authorization roles.
enum UserRoleEnum {
  customer,
  admin,
  unknown;

  static UserRoleEnum fromString(String? value) {
    if (value == null || value.trim().isEmpty) return UserRoleEnum.unknown;
    final String clean = value.trim().toUpperCase();
    switch (clean) {
      case 'CUSTOMER':
        return UserRoleEnum.customer;
      case 'ADMIN':
        return UserRoleEnum.admin;
      default:
        return UserRoleEnum.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case UserRoleEnum.customer:
        return 'CUSTOMER';
      case UserRoleEnum.admin:
        return 'ADMIN';
      case UserRoleEnum.unknown:
        return 'UNKNOWN';
    }
  }
}

/// System notification types.
enum NotificationTypeEnum {
  transaction,
  scheme,
  offer,
  system,
  unknown;

  static NotificationTypeEnum fromString(String? value) {
    if (value == null || value.trim().isEmpty) return NotificationTypeEnum.unknown;
    final String clean = value.trim().toUpperCase();
    switch (clean) {
      case 'TRANSACTION':
      case 'PAYMENT':
        return NotificationTypeEnum.transaction;
      case 'SCHEME':
        return NotificationTypeEnum.scheme;
      case 'OFFER':
        return NotificationTypeEnum.offer;
      case 'SYSTEM':
        return NotificationTypeEnum.system;
      default:
        return NotificationTypeEnum.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case NotificationTypeEnum.transaction:
        return 'TRANSACTION';
      case NotificationTypeEnum.scheme:
        return 'SCHEME';
      case NotificationTypeEnum.offer:
        return 'OFFER';
      case NotificationTypeEnum.system:
        return 'SYSTEM';
      case NotificationTypeEnum.unknown:
        return 'UNKNOWN';
    }
  }
}
