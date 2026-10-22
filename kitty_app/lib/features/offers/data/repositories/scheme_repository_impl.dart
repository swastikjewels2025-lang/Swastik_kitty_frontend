import '../../../../core/config/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/kitty_slot_entity.dart';
import '../../domain/entities/offer_entity.dart';
import '../../domain/entities/scheme_entity.dart';
import '../../domain/repositories/i_offer_repository.dart';
import '../../domain/repositories/i_scheme_repository.dart';
import '../dtos/scheme_dto.dart';
import '../mappers/scheme_mapper.dart';

/// Remote implementation of [ISchemeRepository] and [IOfferRepository].
class SchemeRepositoryImpl implements ISchemeRepository, IOfferRepository {
  SchemeRepositoryImpl({required DioClient apiClient}) : _dio = apiClient;

  final DioClient _dio;

  @override
  Future<List<SchemeEntity>> getActiveSchemes({int? durationFilter}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.schemesActive,
      queryParameters: durationFilter != null
          ? <String, dynamic>{'duration': durationFilter}
          : null,
    );

    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> list = data['schemes'] as List<dynamic>? ?? <dynamic>[];

    return list
        .map((dynamic json) =>
            SchemeMapper.toEntity(SchemeDto.fromJson(json as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<SchemeEntity> getSchemeById(String id) async {
    final List<SchemeEntity> schemes = await getActiveSchemes();
    return schemes.firstWhere(
      (SchemeEntity s) => s.id == id,
      orElse: () => throw const NotFoundException('Scheme not found.'),
    );
  }

  @override
  Future<List<OfferEntity>> getActiveOffers() async {
    // The backend does not expose a dedicated /offers endpoint; promotional offers are
    // derived directly from active scheme privileges and perks (GET /api/v1/schemes/active).
    final List<SchemeEntity> schemes = await getActiveSchemes();
    return schemes.map((SchemeEntity scheme) {
      return OfferEntity(
        id: 'offer_${scheme.id}',
        title: scheme.name,
        description: scheme.benefits.isNotEmpty
            ? scheme.benefits.join(' • ')
            : 'Enroll now and receive 1 Month Free Jeweler Bonus upon maturity.',
        code: 'SWASTIK${scheme.durationMonths}',
        discountPct: 25.0,
        imageUrl: scheme.bannerImageUrl,
      );
    }).toList();
  }

  @override
  Future<List<KittySlotEntity>> getAvailableNumbers(
    String schemeId, {
    int totalCapacity = 50,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.schemesActive}/$schemeId/numbers',
    );

    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> list = data['numbers'] as List<dynamic>? ?? <dynamic>[];

    return list.map((dynamic item) {
      final Map<String, dynamic> json = item as Map<String, dynamic>;
      final int num = json['number'] as int? ?? 1;
      final String statusStr = (json['status'] as String? ?? 'AVAILABLE').toUpperCase();
      final KittySlotStatus status = switch (statusStr) {
        'BOOKED' => KittySlotStatus.booked,
        'LOCKED' => KittySlotStatus.locked,
        _ => KittySlotStatus.available,
      };
      return KittySlotEntity(
        number: num,
        status: status,
        tokenString: json['tokenString'] as String? ?? '#SW-${num.toString().padLeft(3, '0')}',
      );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> enrollScheme({
    required String schemeId,
    required int monthlyAmount,
    required int slotNumber,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.schemesActive}/$schemeId/enroll',
      data: <String, dynamic>{
        'monthlyAmount': monthlyAmount,
        'slotNumber': slotNumber,
      },
    );

    return response.data?['data'] as Map<String, dynamic>? ??
        <String, dynamic>{
          'success': true,
          'membershipId': 'MEM-$slotNumber',
        };
  }
}
