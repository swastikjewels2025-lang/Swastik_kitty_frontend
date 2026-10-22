import '../entities/auth_session_entity.dart';
import '../entities/user_entity.dart';

/// Pure domain repository interface for authentication.
abstract interface class IAuthRepository {
  /// Sends SMS OTP to the provided phone number.
  Future<SendOtpResultEntity> sendOtp({required String phone});

  /// Verifies 6-digit OTP and authenticates user.
  Future<AuthSessionEntity> verifyOtp({
    required String phone,
    required String otp,
    String? sessionId,
  });

  /// Retrieves current authenticated user profile.
  Future<UserEntity> getCurrentUser();

  /// Logs out active user session and clears stored tokens.
  Future<void> logout();
}
