import 'dart:convert';
import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../dtos/auth_dto.dart';
import '../dtos/user_dto.dart';
import '../mappers/auth_mapper.dart';

/// Remote Dio-backed implementation of [IAuthRepository] (Ready for Phase 16 integration).
class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl({
    required DioClient apiClient,
    required SecureStorageService storageService,
  })  : _dio = apiClient,
        _storage = storageService;

  final DioClient _dio;
  final SecureStorageService _storage;

  @override
  Future<SendOtpResultEntity> sendOtp({required String phone}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.authSendOtp,
      data: SendOtpRequestDto(phone: phone).toJson(),
    );

    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return AuthMapper.toSendOtpResultEntity(SendOtpResponseDto.fromJson(data));
  }

  @override
  Future<AuthSessionEntity> verifyOtp({
    required String phone,
    required String otp,
    String? sessionId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.authVerifyOtp,
      data: VerifyOtpRequestDto(phone: phone, otp: otp, sessionId: sessionId).toJson(),
    );

    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final VerifyOtpResponseDto dto = VerifyOtpResponseDto.fromJson(data);

    await _storage.saveToken(dto.token);
    await _storage.saveUserData(jsonEncode(dto.user.toJson()));

    return AuthMapper.toSessionEntity(dto);
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.userProfile);
    final Map<String, dynamic> data =
        response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> userJson =
        (data['user'] as Map<String, dynamic>?) ?? data;
    return AuthMapper.toUserEntity(UserDto.fromJson(userJson));
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.authLogout);
    } catch (_) {
      // Best-effort remote notification
    }
    await _storage.clearSession();
  }
}
