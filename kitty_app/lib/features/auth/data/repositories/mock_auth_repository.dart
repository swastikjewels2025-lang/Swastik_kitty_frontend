import 'dart:convert';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/mock/mock_engine_config.dart';
import '../../../../core/mock/mock_fixtures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../dtos/auth_dto.dart';
import '../dtos/user_dto.dart';
import '../mappers/auth_mapper.dart';

/// Mock implementation of [IAuthRepository] using contract-compliant fixtures.
class MockAuthRepository implements IAuthRepository {
  MockAuthRepository({
    MockEngineConfig? engineConfig,
    SecureStorageService? storageService,
  })  : _engineConfig = engineConfig ?? MockEngineConfig.instance,
        _storage = storageService ?? SecureStorageService();

  final MockEngineConfig _engineConfig;
  final SecureStorageService _storage;

  @override
  Future<SendOtpResultEntity> sendOtp({required String phone}) async {
    await _engineConfig.simulate();

    final String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length < 10) {
      throw const ValidationException(
        'Please enter a valid 10-digit mobile number.',
        'INVALID_PHONE',
        400,
      );
    }

    final SendOtpResponseDto dto = SendOtpResponseDto.fromJson(
      MockFixtures.authSendOtpSuccessJson['data'] as Map<String, dynamic>,
    );

    return AuthMapper.toSendOtpResultEntity(dto);
  }

  @override
  Future<AuthSessionEntity> verifyOtp({
    required String phone,
    required String otp,
    String? sessionId,
  }) async {
    await _engineConfig.simulate();

    // Contract: 123456 is universal sandbox test OTP
    if (otp != '123456' && otp != '984210') {
      throw const ValidationException(
        'Incorrect OTP entered. Please try again or use 123456 for sandbox testing.',
        'INVALID_OTP',
        400,
      );
    }

    final VerifyOtpResponseDto dto = VerifyOtpResponseDto.fromJson(
      MockFixtures.authVerifySuccessJson['data'] as Map<String, dynamic>,
    );

    // Save token and user cache to secure storage
    await _storage.saveToken(dto.token);
    await _storage.saveUserData(jsonEncode(dto.user.toJson()));

    return AuthMapper.toSessionEntity(dto);
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    await _engineConfig.simulate();

    final UserDto dto = UserDto.fromJson(
      MockFixtures.userProfileJson['data'] as Map<String, dynamic>,
    );

    return AuthMapper.toUserEntity(dto);
  }

  @override
  Future<void> logout() async {
    await _engineConfig.simulate();
    await _storage.clearSession();
  }
}
