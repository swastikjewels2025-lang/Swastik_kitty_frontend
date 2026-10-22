import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order_booking_entity.dart';

/// Provider exposing the reactive list of orders and bookings.
final NotifierProvider<OrdersController, List<OrderBookingEntity>> ordersControllerProvider =
    NotifierProvider<OrdersController, List<OrderBookingEntity>>(OrdersController.new);

/// Controller managing patron orders, bookings, and reservations.
class OrdersController extends Notifier<List<OrderBookingEntity>> {
  @override
  List<OrderBookingEntity> build() {
    return const <OrderBookingEntity>[];
  }

  /// Records a new booking or order placed by the user.
  void addBooking(OrderBookingEntity booking) {
    state = <OrderBookingEntity>[booking, ...state];
  }

  /// Clears orders for testing or sign out.
  void clearOrders() {
    state = const <OrderBookingEntity>[];
  }
}
