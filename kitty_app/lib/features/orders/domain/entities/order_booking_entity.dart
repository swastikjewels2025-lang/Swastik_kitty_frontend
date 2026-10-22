import 'package:flutter/foundation.dart';

/// Categories of bookings and orders supported.
enum OrderCategory {
  coins('Coins'),
  jewellery('Jewellery'),
  schemes('Gold Schemes');

  const OrderCategory(this.label);
  final String label;
}

/// Entity representing an order or bullion booking in the Kitty App.
@immutable
class OrderBookingEntity {
  const OrderBookingEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.amount,
    required this.formattedAmount,
    required this.status,
    required this.createdAt,
    this.badgeText,
  });

  final String id;
  final String title;
  final OrderCategory category;
  final String description;
  final double amount;
  final String formattedAmount;
  final String status;
  final DateTime createdAt;
  final String? badgeText;
}
