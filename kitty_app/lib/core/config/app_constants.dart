/// Centralized global application constants for Kitty App.
abstract final class AppConstants {
  // ---------------------------------------------------------------------------
  // App Identity
  // ---------------------------------------------------------------------------

  /// Application display title.
  static const String appName = 'Swastik';

  /// Default currency symbol (Indian Rupee).
  static const String currencySymbol = '₹';

  /// Standard Chit token prefix.
  static const String chitTokenPrefix = '#SW-';

  /// Official Swastik Jewellers showroom web catalog URL.
  static const String jewelleryCatalogUrl = 'https://swastikjewel.in';

  /// Official Swastik Jewellers Instagram profile URL.
  static const String officialInstagramUrl =
      'https://www.instagram.com/swastikjewels_bynitingupta/';

  /// Fallback Swastik Jewellers Instagram profile URL.
  static const String fallbackInstagramUrl =
      'https://www.instagram.com/swastikjewels_bynitingupta/';

  /// Official showroom concierge contact phone number.
  static const String showroomContactPhone = '+919876543210';

  // ---------------------------------------------------------------------------
  // Network Timeouts & Limits
  // ---------------------------------------------------------------------------

  /// Maximum connection timeout for HTTP requests (15s).
  static const Duration connectTimeout = Duration(milliseconds: 15000);

  /// Maximum receive timeout for HTTP requests (15s).
  static const Duration receiveTimeout = Duration(milliseconds: 15000);

  /// Maximum send timeout for HTTP requests (15s).
  static const Duration sendTimeout = Duration(milliseconds: 15000);

  /// Maximum allowed file upload size for KYC documents (10 MB in bytes).
  static const int maxKycFileSizeBytes = 10 * 1024 * 1024;

  // ---------------------------------------------------------------------------
  // Storage Keys (Secure KeyStore / KeyChain)
  // ---------------------------------------------------------------------------

  /// Key for single JWT token in SecureStorage.
  static const String jwtStorageKey = 'kitty_jwt_token';

  /// Key for cached user profile/session in SecureStorage.
  static const String userSessionStorageKey = 'kitty_user_session';

  /// Key for biometric lock preference in SecureStorage.
  static const String biometricEnabledKey = 'kitty_biometric_enabled';

  /// Key for dark/light theme mode preference in SecureStorage.
  static const String themeModeKey = 'kitty_theme_mode';

  /// Key for app language preference in SecureStorage.
  static const String languageKey = 'kitty_language';

  /// Key for UPI AutoPay preference in SecureStorage.
  static const String autoPayEnabledKey = 'kitty_autopay_enabled';

  /// Key for local 4-digit transaction MPIN in SecureStorage.
  static const String mpinKey = 'kitty_mpin';

  /// Key for persisted set of read notification IDs in SecureStorage.
  static const String notificationsReadIdsKey = 'kitty_notifications_read_ids';

  /// Key for locally generated notifications list in SecureStorage.
  static const String notificationsLocalItemsKey = 'kitty_notifications_local_items';

  // ---------------------------------------------------------------------------
  // Validation Rules & Limits
  // ---------------------------------------------------------------------------

  /// Standard Indian mobile phone number length (10 digits).
  static const int phoneLength = 10;

  /// Single-digit OTP length (6 digits).
  static const int otpLength = 6;

  /// OTP resend countdown duration in seconds.
  static const int otpResendCooldownSeconds = 30;

  /// Indian Aadhaar number digit length (12 digits).
  static const int aadhaarLength = 12;

  /// Indian Income Tax PAN length (10 characters).
  static const int panLength = 10;
}
