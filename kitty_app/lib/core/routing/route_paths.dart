/// Centralized URI route path definitions for Kitty App.
///
/// Strictly matches the routes formalised in NAVIGATION.md and FRONTEND_IMPLEMENTATION_PLAN.md.
abstract final class RoutePaths {
  // ---------------------------------------------------------------------------
  // Public & Authentication Branch
  // ---------------------------------------------------------------------------

  /// Initial splash entry screen with 3D diamond animation and session check.
  static const String splash = '/splash';

  /// Primary login screen (Choice between Mobile Number and Google SSO).
  static const String login = '/auth/login';

  /// Mobile phone number entry view.
  static const String phone = '/auth/phone';

  /// 6-digit OTP verification view.
  static const String otp = '/auth/otp';

  /// Profile information registration screen (after phone/OTP verification).
  static const String profile = '/auth/profile';

  /// Authentication confirmation screen.
  static const String authSuccess = '/auth/success';

  /// Post-KYC Onboarding Choice Screen (Instagram, Shop Gold, Shop Jewellery).
  static const String postKycChoice = '/onboarding/choice';

  // ---------------------------------------------------------------------------
  // Protected Application Shell Tabs (5 Canonical Destinations)
  // ---------------------------------------------------------------------------

  /// Tab 0: Home Screen (Brand showcase, promo carousel, category pills).
  static const String home = '/home';

  /// Tab 1: My Kitty Scheme Dashboard (Hero card, circular gauge, stats).
  static const String dashboard = '/dashboard';

  /// Tab 2: Kitty Plans & Offers Screen (Curated savings schemes, plan enrollment).
  static const String offers = '/offers';

  /// Tab 3: Gold Valuation Calculator Screen (Shop by Gram & Shop by Money).
  static const String calculator = '/calculator';

  /// Tab 4: Jewellery Screen (Gold & Diamond jewellery dropdowns & categories).
  static const String jewellery = '/jewellery';

  // ---------------------------------------------------------------------------
  // Protected Drawer & Supporting Stack Routes
  // ---------------------------------------------------------------------------

  /// Dedicated Live Bullion Rates Screen (24K, 22K, 18K, 14K Gold + 999 Silver).
  static const String liveRates = '/live-rates';

  /// Coin Rates Screen (1gm to 10gm gold/silver coin prices, bullion booking via drawer).
  static const String coinRates = '/coin-rates';

  /// Passbook Screen (12-month installment timeline table / cards).
  static const String passbook = '/passbook';

  /// Settings Screen (Security, MPIN, Biometrics, Nominee, Logout).
  static const String settings = '/settings';

  /// Menu Screen (Deep link fallback / patron options).
  static const String menu = '/menu';

  /// Orders & Bookings Screen (Coin orders, jewellery crafting, scheme redemptions).
  static const String orders = '/orders';

  // ---------------------------------------------------------------------------
  // Protected Stack & Modal Routes
  // ---------------------------------------------------------------------------

  /// Notifications center screen.
  static const String notifications = '/notifications';

  /// KYC identity verification screen (Aadhaar / PAN upload).
  static const String kyc = '/kyc';

  /// Payment checkout bottom sheet / modal.
  static const String checkout = '/checkout';

  /// Select Your Numbers screen (dddd/book.html).
  static const String book = '/book';

  /// Review Your Plan screen (dddd/review.html).
  static const String review = '/review';

  /// Doorstep Cash Pickup screen (dddd/cash-pickup.html).
  static const String cashPickup = '/cash-pickup';

  /// Digital tax receipt modal / screen. Parameterized by receipt ID.
  static const String receipt = '/receipt/:id';

  /// Helper to generate parameterized receipt URI.
  static String receiptWithId(String id) => '/receipt/$id';

  /// Third-party payment gateway isolated WebView host.
  static const String gokwikGateway = '/gokwik-gateway';
}
