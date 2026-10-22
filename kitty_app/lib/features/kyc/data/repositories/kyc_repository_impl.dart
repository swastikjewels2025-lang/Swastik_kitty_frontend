import 'package:dio/dio.dart';
import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/repositories/i_kyc_repository.dart';
import '../dtos/kyc_dto.dart';
import '../mappers/kyc_mapper.dart';

/// Remote implementation of [IKycRepository] (Ready for Phase 16 integration).
class KycRepositoryImpl implements IKycRepository {
  KycRepositoryImpl({required DioClient apiClient}) : _dio = apiClient;

  final DioClient _dio;

  @override
  Future<KycResultEntity> submitKyc(KycSubmissionEntity submission) async {
    final Map<String, dynamic> formMap = <String, dynamic>{
      'documentType': submission.documentType.toJson(),
      'documentNumber': submission.documentNumber,
      'consentAgreed': submission.consentAgreed.toString(),
      if (submission.name != null && submission.name!.isNotEmpty)
        'name': submission.name,
    };

    if (submission.filePath != null && submission.filePath!.isNotEmpty) {
      formMap['file'] = await MultipartFile.fromFile(
        submission.filePath!,
        filename: submission.fileName ?? 'kyc_document',
      );
    }

    final FormData formData = FormData.fromMap(formMap);

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.userKyc,
      data: formData,
    );

    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return KycMapper.toEntity(KycSubmitResponseDto.fromJson(data));
  }

  @override
  Future<KycResultEntity> getKycStatus() async {
    final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.userProfile);
    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic>? userMap = data['user'] as Map<String, dynamic>?;
    final Map<String, dynamic> kycMap =
        (userMap?['kyc'] ?? data['kyc']) as Map<String, dynamic>? ?? <String, dynamic>{};
    return KycMapper.toEntity(KycSubmitResponseDto.fromJson(kycMap));
  }
}
