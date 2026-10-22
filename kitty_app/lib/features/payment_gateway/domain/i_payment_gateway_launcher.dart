import 'package:flutter/widgets.dart';
import '../../checkout/domain/entities/payment_order_entity.dart';
import 'gateway_result.dart';

/// Pure domain boundary interface for launching payment gateway experiences.
///
/// Decouples Flutter UI widgets from underlying SDKs (e.g. GoKwik WebView, Native SDK, or Mock Gateway).
abstract interface class IPaymentGatewayLauncher {
  /// Launches the payment experience for the given [order].
  ///
  /// Returns a [GatewayResult] upon dismissal/completion. Note that according to the
  /// architecture contract, client-side gateway completion is NEVER assumed to be final
  /// payment success. Final success is always determined by backend polling reconciliation.
  Future<GatewayResult> launchGateway({
    required BuildContext context,
    required PaymentOrderEntity order,
  });
}
