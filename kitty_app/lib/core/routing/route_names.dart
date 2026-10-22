/// Centralized route names for GoRouter named navigation.
///
/// Matches the master navigation hierarchy from NAVIGATION.md.
enum AppRoute {
  // Public
  splash('splash'),
  login('login'),
  phone('phone'),
  otp('otp'),
  profile('profile'),
  authSuccess('authSuccess'),

  // Shell Tabs
  home('home'),
  coinRates('coinRates'),
  jewellery('jewellery'),
  calculator('calculator'),
  menu('menu'),
  dashboard('dashboard'),
  passbook('passbook'),
  offers('offers'),
  settings('settings'),

  // Supporting / Stack Routes
  liveRates('liveRates'),
  orders('orders'),
  notifications('notifications'),
  kyc('kyc'),
  checkout('checkout'),
  receipt('receipt'),
  gokwikGateway('gokwikGateway'),
  postKycChoice('postKycChoice'),

  // Fallback
  notFound('notFound');

  const AppRoute(this.name);

  /// String identifier matching GoRoute.name.
  final String name;
}
