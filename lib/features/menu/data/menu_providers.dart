import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dish.dart';
import 'menu_repository.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) => MenuRepository());

/// Live stream of every dish in Firestore. Home, Menu, Favorites, and
/// Dish Details all watch this single provider so a change (or the
/// initial seed) shows up everywhere at once, with no manual refresh.
final dishesStreamProvider = StreamProvider<List<Dish>>((ref) {
  return ref.watch(menuRepositoryProvider).streamAll();
});
