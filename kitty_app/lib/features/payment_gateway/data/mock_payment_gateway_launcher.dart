import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_paths.dart';
import '../../checkout/domain/entities/payment_order_entity.dart';
import '../domain/gateway_result.dart';
import '../domain/i_payment_gateway_launcher.dart';

/// Mock implementation of [IPaymentGatewayLauncher] simulating GoKwik Gateway interactions.
class MockPaymentGatewayLauncher implements IPaymentGatewayLauncher {
  MockPaymentGatewayLauncher({this.forcedResult});

  /// Optional forced result to bypass UI navigation in automated unit/controller tests.
  GatewayResult? forcedResult;

  /// Whether gateway has been launched at least once.
  bool hasLaunched = false;

  /// The most recent order launched.
  PaymentOrderEntity? lastOrder;

  @override
  Future<GatewayResult> launchGateway({
    required BuildContext context,
    required PaymentOrderEntity order,
  }) async {
    hasLaunched = true;
    lastOrder = order;

    if (forcedResult != null) {
      return forcedResult!;
    }

    // Push to the isolated GoKwik Gateway screen and await user action
    final dynamic result = await context.push<dynamic>(
      RoutePaths.gokwikGateway,
      extra: order,
    );

    if (result is GatewayResult) {
      return result;
    }

    // Default fallback if user popped or dismissed without explicit selection
    return const GatewayResult.cancelled(
      message: 'Gateway dismissed by user.',
    );
  }
}
