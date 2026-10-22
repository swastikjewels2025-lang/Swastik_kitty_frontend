import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_app/core/enums/app_enums.dart';
import 'package:kitty_app/core/errors/app_exception.dart';
import 'package:kitty_app/core/mock/mock_engine_config.dart';
import 'package:kitty_app/features/passbook/data/dtos/passbook_dto.dart';
import 'package:kitty_app/features/passbook/data/mappers/passbook_mapper.dart';
import 'package:kitty_app/features/passbook/data/repositories/mock_passbook_repository.dart';
import 'package:kitty_app/features/passbook/domain/entities/passbook_entry_entity.dart';
import 'package:kitty_app/features/passbook/domain/entities/passbook_summary_entity.dart';

void main() {
  final MockEngineConfig instantConfig = MockEngineConfig(latency: MockLatency.instant);

  group('Passbook Domain & Data Layer Unit Tests', () {
    test('PassbookEntryDto fromJson and toJson preserves all frozen contract fields', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'month': 1,
        'label': 'Month 1',
        'amount': 5000,
        'status': 'PAID',
        'paidAt': '2026-01-15T10:30:00.000Z',
        'paymentMethod': 'ONLINE',
        'transactionId': 'TXN-SW-10821',
        'goldGrams': 0.702,
        'receiptUrl': 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_10821.pdf',
        'bonusNote': null,
      };

      final PassbookEntryDto dto = PassbookEntryDto.fromJson(json);
      expect(dto.month, 1);
      expect(dto.label, 'Month 1');
      expect(dto.amount, 5000);
      expect(dto.status, 'PAID');
      expect(dto.paidAt, '2026-01-15T10:30:00.000Z');
      expect(dto.paymentMethod, 'ONLINE');
      expect(dto.transactionId, 'TXN-SW-10821');
      expect(dto.goldGrams, 0.702);
      expect(dto.receiptUrl, 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_10821.pdf');

      final Map<String, dynamic> serialized = dto.toJson();
      expect(serialized['month'], 1);
      expect(serialized['amount'], 5000);
      expect(serialized['status'], 'PAID');
      expect(serialized['transactionId'], 'TXN-SW-10821');
    });

    test('PassbookMapper.toEntity accurately maps DTO to domain entity', () {
      const PassbookEntryDto dto = PassbookEntryDto(
        month: 2,
        label: 'Month 2',
        amount: 5000,
        status: 'PAID',
        paidAt: '2026-02-15T11:15:00.000Z',
        dueDate: '2026-02-15T00:00:00.000Z',
        paymentMethod: 'ONLINE',
        transactionId: 'TXN-SW-10822',
        goldGrams: 0.695,
        receiptUrl: 'https://example.com/receipt.pdf',
      );

      final PassbookEntryEntity entity = PassbookMapper.toEntity(dto);
      expect(entity.month, 2);
      expect(entity.label, 'Month 2');
      expect(entity.amount, 5000); // Whole integer rupees
      expect(entity.status, InstallmentStatusEnum.paid);
      expect(entity.isPaid, isTrue);
      expect(entity.isCurrent, isFalse);
      expect(entity.isBonus, isFalse);
      expect(entity.isPreJoin, isFalse);
      expect(entity.paidAt, isNotNull);
      expect(entity.paidAt!.isUtc, isTrue);
      expect(entity.paymentMethod, PaymentMethodEnum.online);
      expect(entity.transactionId, 'TXN-SW-10822');
      expect(entity.goldGrams, 0.695);
    });

    test('PassbookMapper handles edge and unknown statuses safely', () {
      const PassbookEntryDto dto = PassbookEntryDto(
        month: 12,
        label: 'Month 12',
        amount: 5000,
        status: 'BONUS',
        bonusNote: '100% Jeweler Bonus Deposit on completion',
      );

      final PassbookEntryEntity entity = PassbookMapper.toEntity(dto);
      expect(entity.status, InstallmentStatusEnum.bonus);
      expect(entity.isBonus, isTrue);
      expect(entity.bonusNote, '100% Jeweler Bonus Deposit on completion');

      // Unknown status
      const PassbookEntryDto unknownDto = PassbookEntryDto(
        month: 13,
        label: 'Month 13',
        amount: 5000,
        status: 'UNRECOGNIZED_STATUS_VAL',
      );
      final PassbookEntryEntity unknownEntity = PassbookMapper.toEntity(unknownDto);
      expect(unknownEntity.status, InstallmentStatusEnum.unknown);
    });

    test('PassbookSummaryEntity calculates remainingMonths correctly', () {
      const PassbookSummaryEntity summary = PassbookSummaryEntity(
        chitToken: '#SW-042',
        schemeName: 'Swastik Suvarna Varsha',
        totalMonths: 12,
        monthsPaid: 8,
        monthlyEmi: 5000,
        totalPaid: 40000,
        accumulatedGoldGrams: 5.482,
      );

      expect(summary.remainingMonths, 4);
      expect(summary.totalPaid, 40000);
      expect(summary.isPreJoin, isFalse);
    });

    test('MockPassbookRepository delivers 12-month passbook ledger in default scenario', () async {
      final MockPassbookRepository repository = MockPassbookRepository(engineConfig: instantConfig);

      final List<PassbookEntryEntity> entries = await repository.getPassbookEntries();
      expect(entries.length, 12);
      expect(entries.first.month, 1);
      expect(entries.first.isPaid, isTrue);
      expect(entries[8].month, 9);
      expect(entries[8].isCurrent, isTrue);
      expect(entries.last.month, 12);
      expect(entries.last.isBonus, isTrue);

      final PassbookSummaryEntity? summary = await repository.getPassbookSummary();
      expect(summary, isNotNull);
      expect(summary!.chitToken, '#SW-042');
      expect(summary.totalMonths, 12);
      expect(summary.monthsPaid, 8);
      expect(summary.totalPaid, 40000);
      expect(summary.accumulatedGoldGrams, 5.482);
    });

    test('MockPassbookRepository handles empty and custom scenarios', () async {
      final MockPassbookRepository repository = MockPassbookRepository(engineConfig: instantConfig);

      repository.setHasActiveScheme(false);
      final List<PassbookEntryEntity> emptyEntries = await repository.getPassbookEntries();
      expect(emptyEntries, isEmpty);
      final PassbookSummaryEntity? emptySummary = await repository.getPassbookSummary();
      expect(emptySummary, isNull);

      repository.setHasActiveScheme(true);
      repository.setCustomEntries(<PassbookEntryEntity>[
        const PassbookEntryEntity(
          month: 1,
          label: 'Month 1',
          amount: 5000,
          status: InstallmentStatusEnum.paid,
        ),
      ]);
      final List<PassbookEntryEntity> single = await repository.getPassbookEntries();
      expect(single.length, 1);
      expect(single.first.month, 1);
    });

    test('MockPassbookRepository throws AppException when setShouldThrow(true)', () async {
      final MockPassbookRepository repository = MockPassbookRepository(engineConfig: instantConfig);
      repository.setShouldThrow(true);

      expect(() => repository.getPassbookEntries(), throwsA(isA<AppException>()));
      expect(() => repository.getPassbookSummary(), throwsA(isA<AppException>()));
    });
  });
}
