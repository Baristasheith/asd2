import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { preparing, onTheWay, delivered, cancelled }

class OrderItem {
  final String dishName;
  final int quantity;
  const OrderItem({required this.dishName, required this.quantity});

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        dishName: map['dishName'] as String? ?? '',
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toMap() => {'dishName': dishName, 'quantity': quantity};
}

class Order {
  final String id;
  final DateTime date;
  final OrderStatus status;
  final double total;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.date,
    required this.status,
    required this.total,
    required this.items,
  });

  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final timestamp = data['createdAt'] as Timestamp?;
    return Order(
      id: doc.id,
      date: timestamp?.toDate() ?? DateTime.now(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => OrderStatus.preparing,
      ),
      total: (data['total'] as num?)?.toDouble() ?? 0,
      items: ((data['items'] as List<dynamic>?) ?? [])
          .map((raw) => OrderItem.fromMap(raw as Map<String, dynamic>))
          .toList(),
    );
  }
}
