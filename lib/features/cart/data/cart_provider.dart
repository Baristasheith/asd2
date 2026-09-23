import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_provider.dart';
import '../../menu/data/menu_providers.dart';
import '../../menu/domain/dish.dart';
import 'cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) => CartRepository());

/// Live map of dishId -> quantity for the signed-in user's cart. Empty
/// (never null) when signed out, so screens don't need extra null
/// checks — Cart is only reachable after auth anyway.
final cartStreamProvider = StreamProvider<Map<String, int>>((ref) {
  final uid = ref.watch(authProvider)?.uid;
  if (uid == null) return Stream.value(<String, int>{});
  return ref.watch(cartRepositoryProvider).streamCart(uid);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartStreamProvider).maybeWhen(data: (c) => c, orElse: () => <String, int>{});
  return cart.values.fold(0, (a, b) => a + b);
});

/// Resolves cart quantities against the live dish catalog so screens
/// get ready-to-render `(Dish, quantity)` pairs plus the subtotal,
/// instead of re-deriving this in every widget.
final cartItemsProvider = Provider<List<MapEntry<Dish, int>>>((ref) {
  final cart = ref.watch(cartStreamProvider).maybeWhen(data: (c) => c, orElse: () => <String, int>{});
  final dishes = ref.watch(dishesStreamProvider).maybeWhen(data: (d) => d, orElse: () => <Dish>[]);
  final byId = {for (final d in dishes) d.id: d};

  return cart.entries
      .where((e) => byId.containsKey(e.key))
      .map((e) => MapEntry(byId[e.key]!, e.value))
      .toList();
});

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartItemsProvider).fold(0.0, (sum, entry) => sum + entry.key.price * entry.value);
});

/// Thin façade so screens can call `ref.read(cartControllerProvider).add(id)`
/// without threading the current uid through every call site.
class CartController {
  CartController(this._ref);
  final Ref _ref;

  String? get _uid => _ref.read(authProvider)?.uid;

  Future<void> add(String dishId) async {
    final uid = _uid;
    if (uid == null) return;
    await _ref.read(cartRepositoryProvider).add(uid, dishId);
  }

  Future<void> decrement(String dishId) async {
    final uid = _uid;
    if (uid == null) return;
    final currentQty = _ref.read(cartStreamProvider).maybeWhen(data: (c) => c[dishId] ?? 0, orElse: () => 0);
    await _ref.read(cartRepositoryProvider).decrement(uid, dishId, currentQty);
  }

  Future<void> remove(String dishId) async {
    final uid = _uid;
    if (uid == null) return;
    await _ref.read(cartRepositoryProvider).remove(uid, dishId);
  }

  Future<void> clear() async {
    final uid = _uid;
    if (uid == null) return;
    await _ref.read(cartRepositoryProvider).clear(uid);
  }
}

final cartControllerProvider = Provider<CartController>((ref) => CartController(ref));
