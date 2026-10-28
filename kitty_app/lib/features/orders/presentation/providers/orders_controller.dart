import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/order_booking_entity.dart';

/// Provider exposing the reactive list of orders and bookings.
final NotifierProvider<OrdersController, List<OrderBookingEntity>> ordersControllerProvider =
    NotifierProvider<OrdersController, List<OrderBookingEntity>>(OrdersController.new);

/// Controller managing patron orders, bookings, and reservations.
class OrdersController extends Notifier<List<OrderBookingEntity>> {
  @override
  List<OrderBookingEntity> build() {
    loadBookings();
    return const <OrderBookingEntity>[];
  }

  /// Fetches confirmed bookings from the backend (GET /api/v1/bookings).
  Future<void> loadBookings() async {
    try {
      final DioClient dio = ref.read(dioClientProvider);
      final response = await dio.get<Map<String, dynamic>>('/api/v1/bookings');
      final dynamic data = response.data?['data'];
      final List<dynamic>? rawBookings =
          data is Map ? (data['bookings'] as List<dynamic>?) : null;

      if (rawBookings != null) {
        final List<OrderBookingEntity> loaded = rawBookings.map((dynamic b) {
          final Map<String, dynamic> map = b as Map<String, dynamic>;
          final double amt = (map['totalAmount'] as num?)?.toDouble() ?? 0.0;
          return OrderBookingEntity(
            id: map['bookingId']?.toString() ?? map['id']?.toString() ?? 'COIN',
            title: map['itemName']?.toString() ?? 'Gold Coin',
            category: OrderCategory.coins,
            description: '${map['weightGrams']} Grams • ${map['karat'] ?? '24K'}',
            amount: amt,
            formattedAmount: '₹$amt',
            status: map['status']?.toString() ?? 'Confirmed',
            createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
            badgeText: map['karat']?.toString() ?? '24K',
          );
        }).toList();
        state = loaded;
      }
    } catch (_) {
      // Retain existing state if unauthenticated or network error
    }
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
