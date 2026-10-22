import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../domain/entities/passbook_entry_entity.dart';
import '../../domain/entities/passbook_summary_entity.dart';
import '../../domain/repositories/i_passbook_repository.dart';
import '../dtos/passbook_dto.dart';
import '../mappers/passbook_mapper.dart';

/// Mock implementation of [IPassbookRepository].
class MockPassbookRepository implements IPassbookRepository {
  MockPassbookRepository({MockEngineConfig? engineConfig})
      : _engineConfig = engineConfig ?? MockEngineConfig.instance;

  final MockEngineConfig _engineConfig;
  bool _hasActiveScheme = true;
  bool _shouldThrow = false;
  List<PassbookEntryEntity>? _customEntries;

  /// Sets whether user has an active kitty scheme.
  void setHasActiveScheme(bool hasActive) {
    _hasActiveScheme = hasActive;
  }

  /// Forces throwing network exception to test error handling and retry.
  void setShouldThrow(bool shouldThrow) {
    _shouldThrow = shouldThrow;
  }

  /// Overrides passbook entries with a custom list (for single record, failed, or edge tests).
  void setCustomEntries(List<PassbookEntryEntity>? entries) {
    _customEntries = entries;
  }

  @override
  Future<PassbookSummaryEntity?> getPassbookSummary({
    String? membershipId,
  }) async {
    await _engineConfig.simulate();

    if (_shouldThrow) {
      throw const NetworkException('Failed to retrieve passbook summary.');
    }

    if (!_hasActiveScheme) {
      return null;
    }

    final Map<String, dynamic> dashboard =
        MockFixtures.dashboardActiveSuvarnaJson['data']['dashboard']
            as Map<String, dynamic>;

    final int monthsPaid = dashboard['monthsPaid'] as int? ?? 8;
    final int monthlyEmi = dashboard['customMonthlyEmi'] as int? ?? 5000;
    final int totalPaid = (dashboard['totalPaidAmount'] as int?) ?? (monthsPaid * monthlyEmi);
    final String status = dashboard['status'] as String? ?? 'ACTIVE';

    return PassbookSummaryEntity(
      chitToken: dashboard['chitToken'] as String? ?? '#SW-042',
      schemeName: dashboard['schemeName'] as String? ??
          'Swastik Swarna Varsha',
      totalMonths: dashboard['totalMonths'] as int? ?? 12,
      monthsPaid: monthsPaid,
      monthlyEmi: monthlyEmi,
      totalPaid: totalPaid,
      accumulatedGoldGrams:
          (dashboard['accumulatedGoldGrams'] as num?)?.toDouble() ?? 5.482,
      isPreJoin: status == 'PRE_JOIN',
    );
  }

  @override
  Future<List<PassbookEntryEntity>> getPassbookEntries({
    String? membershipId,
  }) async {
    await _engineConfig.simulate();

    if (_shouldThrow) {
      throw const NetworkException('Failed to retrieve passbook entries.');
    }

    if (!_hasActiveScheme) {
      return const <PassbookEntryEntity>[];
    }

    if (_customEntries != null) {
      return _customEntries!;
    }

    final List<dynamic> rawList = MockFixtures.dashboardActiveSuvarnaJson[
        'data']['dashboard']['passbook'] as List<dynamic>;

    return rawList
        .map((dynamic json) => PassbookMapper.toEntity(
            PassbookEntryDto.fromJson(json as Map<String, dynamic>)))
        .toList();
  }
}

