import '../../../../core/network/dio_client.dart';
import '../../domain/entities/passbook_entry_entity.dart';
import '../../domain/entities/passbook_summary_entity.dart';
import '../../domain/repositories/i_passbook_repository.dart';
import '../dtos/passbook_dto.dart';
import '../mappers/passbook_mapper.dart';

/// Remote implementation of [IPassbookRepository].
class PassbookRepositoryImpl implements IPassbookRepository {
  PassbookRepositoryImpl({required DioClient apiClient}) : _dio = apiClient;

  final DioClient _dio;

  @override
  Future<PassbookSummaryEntity?> getPassbookSummary({
    String? membershipId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/memberships/my-dashboard');
    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final bool hasActiveScheme = data['hasActiveScheme'] as bool? ?? false;
    final Map<String, dynamic>? dashboard =
        data['dashboard'] as Map<String, dynamic>?;

    if (!hasActiveScheme || dashboard == null) {
      return null;
    }

    final int monthsPaid = dashboard['monthsPaid'] as int? ?? 0;
    final int monthlyEmi = dashboard['customMonthlyEmi'] as int? ?? 0;
    final int totalPaid = (dashboard['totalPaidAmount'] as int?) ?? (monthsPaid * monthlyEmi);
    final String status = dashboard['status'] as String? ?? 'ACTIVE';

    return PassbookSummaryEntity(
      chitToken: dashboard['chitToken'] as String? ?? '',
      schemeName: dashboard['schemeName'] as String? ?? '',
      totalMonths: dashboard['totalMonths'] as int? ?? 12,
      monthsPaid: monthsPaid,
      monthlyEmi: monthlyEmi,
      totalPaid: totalPaid,
      accumulatedGoldGrams:
          (dashboard['accumulatedGoldGrams'] as num?)?.toDouble() ?? 0.0,
      isPreJoin: status == 'PRE_JOIN',
    );
  }

  @override
  Future<List<PassbookEntryEntity>> getPassbookEntries({
    String? membershipId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/memberships/my-dashboard');
    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> list =
        data['dashboard']?['passbook'] as List<dynamic>? ?? <dynamic>[];

    return list
        .map((dynamic json) => PassbookMapper.toEntity(
            PassbookEntryDto.fromJson(json as Map<String, dynamic>)))
        .toList();
  }
}

