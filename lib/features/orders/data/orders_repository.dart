import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/order.dart';

/// Reads/writes `users/{uid}/orders/{orderId}`. Orders are append-only
/// from the app's side (no edit UI) — status changes would normally
/// come from a kitchen/admin system updating the same document.
class OrdersRepository {
  CollectionReference<Map<String, dynamic>> _ordersRef(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('orders');

  Stream<List<Order>> streamOrders(String uid) {
    return _ordersRef(uid).orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map(Order.fromFirestore).toList(),
        );
  }

  Future<void> createOrder(
    String uid, {
    required List<OrderItem> items,
    required double total,
  }) async {
    await _ordersRef(uid).add({
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'status': OrderStatus.preparing.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
