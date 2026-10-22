import '../../../../core/network/dio_client.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/entities/membership_entity.dart';
import '../../domain/repositories/i_dashboard_repository.dart';
import '../../domain/repositories/i_membership_repository.dart';
import '../dtos/dashboard_dto.dart';
import '../dtos/membership_dto.dart';
import '../mappers/dashboard_mapper.dart';
import '../mappers/membership_mapper.dart';

/// Remote implementation of [IDashboardRepository] and [IMembershipRepository].
class DashboardRepositoryImpl
    implements IDashboardRepository, IMembershipRepository {
  DashboardRepositoryImpl({required DioClient apiClient}) : _dio = apiClient;

  final DioClient _dio;

  @override
  Future<DashboardSummaryEntity> getMyDashboard() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/memberships/my-dashboard');
    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return DashboardMapper.toEntity(
        DashboardSummaryResponseDto.fromJson(data));
  }

  @override
  Future<List<DashboardSummaryEntity>> getMySchemes() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/v1/memberships/my-schemes');
      final dynamic rawList = response.data?['data'];
      if (rawList is List) {
        return rawList
            .map((dynamic item) => DashboardMapper.toEntity(
                DashboardSummaryResponseDto.fromJson(item as Map<String, dynamic>)))
            .toList();
      }
    } catch (_) {
      // Graceful fallback to single active dashboard
    }
    final DashboardSummaryEntity single = await getMyDashboard();
    return <DashboardSummaryEntity>[single];
  }

  @override
  Future<MembershipEntity> joinScheme({required String schemeId}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/memberships/join',
      data: JoinSchemeRequestDto(schemeId: schemeId).toJson(),
    );
    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return MembershipMapper.toEntity(
        JoinSchemeResponseDto.fromJson(data).membership);
  }

  @override
  Future<MembershipEntity> getMembershipById(String membershipId) async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/memberships/$membershipId');
    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return MembershipMapper.toEntity(MembershipDto.fromJson(data));
  }
}
