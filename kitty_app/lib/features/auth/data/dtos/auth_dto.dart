import 'user_dto.dart';

/// Request DTO for sending phone OTP.
class SendOtpRequestDto {
  const SendOtpRequestDto({required this.phone});

  final String phone;

  Map<String, dynamic> toJson() => <String, dynamic>{'phone': phone};
}

/// Response DTO for sending phone OTP.
class SendOtpResponseDto {
  const SendOtpResponseDto({
    required this.sessionId,
    required this.expiresInSeconds,
    this.isExistingUser = false,
    this.userName,
    this.message,
  });

  factory SendOtpResponseDto.fromJson(Map<String, dynamic> json) {
    return SendOtpResponseDto(
      sessionId: json['sessionId'] as String? ?? json['phone'] as String? ?? '',
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 300,
      isExistingUser: json['isExistingUser'] as bool? ?? false,
      userName: json['userName'] as String?,
      message: json['message'] as String?,
    );
  }

  final String sessionId;
  final int expiresInSeconds;
  final bool isExistingUser;
  final String? userName;
  final String? message;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'sessionId': sessionId,
        'expiresInSeconds': expiresInSeconds,
        'isExistingUser': isExistingUser,
        if (userName != null) 'userName': userName,
        if (message != null) 'message': message,
      };
}

/// Request DTO for verifying OTP.
class VerifyOtpRequestDto {
  const VerifyOtpRequestDto({
    required this.phone,
    required this.otp,
    this.sessionId,
  });

  final String phone;
  final String otp;
  final String? sessionId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'phone': phone,
        'otp': otp,
        if (sessionId != null) 'sessionId': sessionId,
      };
}

/// Response DTO for verifying OTP.
class VerifyOtpResponseDto {
  const VerifyOtpResponseDto({
    required this.token,
    required this.user,
    this.isNewUser = false,
  });

  factory VerifyOtpResponseDto.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseDto(
      token: json['token'] as String? ?? '',
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }

  final String token;
  final UserDto user;
  final bool isNewUser;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'token': token,
        'user': user.toJson(),
        'isNewUser': isNewUser,
      };
}
