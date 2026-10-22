import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_payment_gateway_launcher.dart';
import '../../domain/i_payment_gateway_launcher.dart';

/// Provider for [IPaymentGatewayLauncher].
///
/// In Phase 11, returns [MockPaymentGatewayLauncher]. In Phase 16, this provider
/// will swap to the production GoKwik SDK implementation without modifying UI consumers.
final Provider<IPaymentGatewayLauncher> paymentGatewayLauncherProvider =
    Provider<IPaymentGatewayLauncher>((Ref ref) {
  return MockPaymentGatewayLauncher();
});
