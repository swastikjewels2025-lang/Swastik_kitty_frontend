import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';

void main() {
  group('AppEnums Defensive Parsing & Serialization Tests', () {
    test('InstallmentStatusEnum fromString and toJson', () {
      expect(InstallmentStatusEnum.fromString('PAID'), InstallmentStatusEnum.paid);
      expect(InstallmentStatusEnum.fromString('CURRENT'), InstallmentStatusEnum.current);
      expect(InstallmentStatusEnum.fromString('UPCOMING'), InstallmentStatusEnum.upcoming);
      expect(InstallmentStatusEnum.fromString('BONUS'), InstallmentStatusEnum.bonus);
      expect(InstallmentStatusEnum.fromString('PRE_JOIN'), InstallmentStatusEnum.preJoin);
      expect(InstallmentStatusEnum.fromString('DEFAULTED'), InstallmentStatusEnum.defaulted);
      expect(InstallmentStatusEnum.fromString('INVALID_VAL'), InstallmentStatusEnum.unknown);
      expect(InstallmentStatusEnum.fromString(null), InstallmentStatusEnum.unknown);

      expect(InstallmentStatusEnum.paid.toJson(), 'PAID');
      expect(InstallmentStatusEnum.bonus.toJson(), 'BONUS');
    });

    test('MembershipStatusEnum fromString and toJson', () {
      expect(MembershipStatusEnum.fromString('ACTIVE'), MembershipStatusEnum.active);
      expect(MembershipStatusEnum.fromString('WINNER'), MembershipStatusEnum.winner);
      expect(MembershipStatusEnum.fromString('COMPLETED'), MembershipStatusEnum.completed);
      expect(MembershipStatusEnum.fromString('DEFAULTED'), MembershipStatusEnum.defaulted);
      expect(MembershipStatusEnum.fromString(null), MembershipStatusEnum.unknown);

      expect(MembershipStatusEnum.active.toJson(), 'ACTIVE');
      expect(MembershipStatusEnum.winner.toJson(), 'WINNER');
    });

    test('KycStatusEnum fromString and toJson', () {
      expect(KycStatusEnum.fromString('NOT_SUBMITTED'), KycStatusEnum.notSubmitted);
      expect(KycStatusEnum.fromString('PENDING'), KycStatusEnum.pending);
      expect(KycStatusEnum.fromString('VERIFIED'), KycStatusEnum.verified);
      expect(KycStatusEnum.fromString('REJECTED'), KycStatusEnum.rejected);
      expect(KycStatusEnum.fromString('RANDOM'), KycStatusEnum.unknown);

      expect(KycStatusEnum.verified.toJson(), 'VERIFIED');
    });

    test('DocTypeEnum fromString and toJson', () {
      expect(DocTypeEnum.fromString('AADHAAR'), DocTypeEnum.aadhaar);
      expect(DocTypeEnum.fromString('PAN'), DocTypeEnum.pan);
      expect(DocTypeEnum.fromString('OTHER'), DocTypeEnum.unknown);
      expect(DocTypeEnum.fromString(null), DocTypeEnum.unknown);

      expect(DocTypeEnum.aadhaar.toJson(), 'AADHAAR');
      expect(DocTypeEnum.pan.toJson(), 'PAN');
    });

    test('PaymentMethodEnum fromString and toJson', () {
      expect(PaymentMethodEnum.fromString('ONLINE'), PaymentMethodEnum.online);
      expect(PaymentMethodEnum.fromString('UPI'), PaymentMethodEnum.online);
      expect(PaymentMethodEnum.fromString('CASH'), PaymentMethodEnum.cash);
      expect(PaymentMethodEnum.fromString('UNKNOWN_METH'), PaymentMethodEnum.unknown);

      expect(PaymentMethodEnum.online.toJson(), 'ONLINE');
      expect(PaymentMethodEnum.cash.toJson(), 'CASH');
    });

    test('PaymentStatusEnum fromString and toJson', () {
      expect(PaymentStatusEnum.fromString('PENDING'), PaymentStatusEnum.pending);
      expect(PaymentStatusEnum.fromString('SUCCESS'), PaymentStatusEnum.success);
      expect(PaymentStatusEnum.fromString('FAILED'), PaymentStatusEnum.failed);
      expect(PaymentStatusEnum.fromString('CANCELLED'), PaymentStatusEnum.cancelled);
      expect(PaymentStatusEnum.fromString('UNKNOWN_STAT'), PaymentStatusEnum.unknown);

      expect(PaymentStatusEnum.success.toJson(), 'SUCCESS');
      expect(PaymentStatusEnum.cancelled.toJson(), 'CANCELLED');
    });

    test('NotificationTypeEnum fromString and toJson', () {
      expect(NotificationTypeEnum.fromString('TRANSACTION'), NotificationTypeEnum.transaction);
      expect(NotificationTypeEnum.fromString('SCHEME'), NotificationTypeEnum.scheme);
      expect(NotificationTypeEnum.fromString('OFFER'), NotificationTypeEnum.offer);
      expect(NotificationTypeEnum.fromString('SYSTEM'), NotificationTypeEnum.system);
      expect(NotificationTypeEnum.fromString(null), NotificationTypeEnum.unknown);

      expect(NotificationTypeEnum.scheme.toJson(), 'SCHEME');
      expect(NotificationTypeEnum.offer.toJson(), 'OFFER');
    });

    test('UserRoleEnum fromString and toJson', () {
      expect(UserRoleEnum.fromString('CUSTOMER'), UserRoleEnum.customer);
      expect(UserRoleEnum.fromString('ADMIN'), UserRoleEnum.admin);
      expect(UserRoleEnum.fromString(null), UserRoleEnum.unknown);

      expect(UserRoleEnum.customer.toJson(), 'CUSTOMER');
      expect(UserRoleEnum.admin.toJson(), 'ADMIN');
    });
  });
}
