import 'user_entity.dart';

/// Domain entity representing an active authenticated session.
class AuthSessionEntity {
  const AuthSessionEntity({
    required this.token,
    required this.user,
    this.isNewUser = false,
  });

  final String token;
  final UserEntity user;
  final bool isNewUser;

  AuthSessionEntity copyWith({
    String? token,
    UserEntity? user,
    bool? isNewUser,
  }) {
    return AuthSessionEntity(
      token: token ?? this.token,
      user: user ?? this.user,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

/// Result of sending an SMS OTP.
class SendOtpResultEntity {
  const SendOtpResultEntity({
    required this.sessionId,
    required this.expiresInSeconds,
    this.isExistingUser = false,
    this.userName,
    this.message,
  });

  final String sessionId;
  final int expiresInSeconds;
  final bool isExistingUser;
  final String? userName;
  final String? message;
}
