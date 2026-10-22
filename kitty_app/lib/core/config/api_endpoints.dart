/// Canonical REST URI endpoints for Kitty App adhering to Frozen Backend Contract v1.0
/// and verified actual backend routes.
abstract final class ApiEndpoints {
  // Base path prefix
  static const String apiVersion = '/api/v1';

  // ---------------------------------------------------------------------------
  // Authentication (/api/v1/auth/*)
  // ---------------------------------------------------------------------------

  /// Request SMS OTP for mobile login.
  static const String authSendOtp = '$apiVersion/auth/send-otp';

  /// Verify 6-digit OTP and obtain 30-day JWT.
  static const String authVerifyOtp = '$apiVersion/auth/verify-otp';

  /// Invalidate server session and logout.
  static const String authLogout = '$apiVersion/auth/logout';

  // ---------------------------------------------------------------------------
  // User Profile & Statutory KYC Compliance (/api/v1/users/*)
  // ---------------------------------------------------------------------------

  /// Fetch authenticated user profile (including nested KYC compliance status).
  static const String userProfile = '$apiVersion/users/profile';

  /// Upload statutory KYC identity document (multipart/form-data with 'file').
  static const String userKyc = '$apiVersion/users/kyc';

  // ---------------------------------------------------------------------------
  // Schemes Discovery (/api/v1/schemes/*)
  // ---------------------------------------------------------------------------

  /// Discover active savings schemes (supports optional ?duration= query param).
  static const String schemesActive = '$apiVersion/schemes/active';

  // ---------------------------------------------------------------------------
  // Memberships & Dashboard (/api/v1/memberships/*)
  // ---------------------------------------------------------------------------

  /// Enroll / join an open scheme with dynamic late-joiner EMI calculation.
  static const String membershipsJoin = '$apiVersion/memberships/join';

  /// Active scheme summary, gold valuation, next EMI due, and 12-month passbook array.
  static const String membershipsDashboard = '$apiVersion/memberships/my-dashboard';

  // ---------------------------------------------------------------------------
  // Payments (/api/v1/payments/*)
  // ---------------------------------------------------------------------------

  /// Initiate GoKwik payment order for a monthly installment.
  static const String paymentsInitiate = '$apiVersion/payments/initiate';

  /// Poll GoKwik payment transaction status by order ID.
  static String paymentsStatus(String orderId) => '$apiVersion/payments/status/$orderId';

  // ---------------------------------------------------------------------------
  // Live Gold Rate Benchmark (/api/v1/rates/*)
  // ---------------------------------------------------------------------------

  /// Live benchmark gold rate per gram (24K and 22K).
  static const String ratesGold = '$apiVersion/rates/gold';
}
