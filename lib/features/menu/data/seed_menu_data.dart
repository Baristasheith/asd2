import '../domain/dish.dart';

/// One-time seed catalog written into Firestore's `dishes` collection
/// the first time the app runs against an empty database (see
/// `MenuRepository.seedIfEmpty`). This is a bootstrap convenience for
/// development/demo, NOT the runtime data source — once seeded, all
/// screens read live from Firestore. A real deployment would replace
/// this with a proper admin/CMS flow and remove the auto-seed call.
class SeedMenuData {
  SeedMenuData._();

  static const List<Dish> dishes = [
    Dish(
      id: 'd1',
      name: 'Saffron Lamb Shank',
      description: 'Slow-braised lamb, saffron jus, roasted root vegetables',
      price: 28.50,
      category: DishCategory.mainCourse,
      isFeatured: true,
    ),
    Dish(
      id: 'd2',
      name: 'Truffle Burrata',
      description: 'Creamy burrata, black truffle shavings, aged balsamic',
      price: 16.00,
      category: DishCategory.starters,
      isFeatured: true,
    ),
    Dish(
      id: 'd3',
      name: 'Gold Leaf Tiramisu',
      description: 'Espresso-soaked ladyfingers, mascarpone, 24k gold leaf',
      price: 12.00,
      category: DishCategory.desserts,
      isFeatured: true,
    ),
    Dish(
      id: 'd4',
      name: 'Wagyu Sliders',
      description: 'A5 wagyu, brioche bun, truffle aioli',
      price: 24.00,
      category: DishCategory.mainCourse,
    ),
    Dish(
      id: 'd5',
      name: 'Seared Foie Gras',
      description: 'Pan-seared foie gras, fig compote, brioche toast',
      price: 22.00,
      category: DishCategory.starters,
    ),
    Dish(
      id: 'd6',
      name: 'Rose & Pistachio Cake',
      description: 'Rosewater sponge, pistachio cream, edible petals',
      price: 11.00,
      category: DishCategory.desserts,
    ),
    Dish(
      id: 'd7',
      name: 'Signature Gold Latte',
      description: 'Espresso, saffron milk, hint of honey',
      price: 7.50,
      category: DishCategory.beverages,
    ),
    Dish(
      id: 'd8',
      name: 'Sparkling Rose Lemonade',
      description: 'House-made lemonade, rose water, soda',
      price: 6.50,
      category: DishCategory.beverages,
    ),
  ];
}
