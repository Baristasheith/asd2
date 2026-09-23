import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_provider.dart';
import '../domain/order.dart';
import 'orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) => OrdersRepository());

/// Live order history for the signed-in user, newest first.
final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  final uid = ref.watch(authProvider)?.uid;
  if (uid == null) return Stream.value(<Order>[]);
  return ref.watch(ordersRepositoryProvider).streamOrders(uid);
});
