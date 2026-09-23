import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_provider.dart';
import '../../menu/data/menu_providers.dart';
import '../../menu/domain/dish.dart';
import 'favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) => FavoritesRepository());

/// Live set of favorited dish IDs for the signed-in user. Empty when
/// signed out — Favorites is only reachable after auth anyway.
final favoritesProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(authProvider)?.uid;
  if (uid == null) return Stream.value(<String>{});
  return ref.watch(favoritesRepositoryProvider).streamIds(uid);
});

/// Resolves favorited IDs against the live dish catalog so Favorites
/// screen gets ready-to-render `Dish` objects directly.
final favoriteDishesProvider = Provider<List<Dish>>((ref) {
  final ids = ref.watch(favoritesProvider).maybeWhen(data: (s) => s, orElse: () => <String>{});
  final dishes = ref.watch(dishesStreamProvider).maybeWhen(data: (d) => d, orElse: () => <Dish>[]);
  return dishes.where((d) => ids.contains(d.id)).toList();
});

class FavoritesController {
  FavoritesController(this._ref);
  final Ref _ref;

  Future<void> toggle(String dishId) async {
    final uid = _ref.read(authProvider)?.uid;
    if (uid == null) return;
    final ids = _ref.read(favoritesProvider).maybeWhen(data: (s) => s, orElse: () => <String>{});
    final repo = _ref.read(favoritesRepositoryProvider);
    if (ids.contains(dishId)) {
      await repo.remove(uid, dishId);
    } else {
      await repo.add(uid, dishId);
    }
  }
}

final favoritesControllerProvider = Provider<FavoritesController>((ref) => FavoritesController(ref));
