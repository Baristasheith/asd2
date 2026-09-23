import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/generated/app_localizations.dart';
import '../widgets/luxury_bottom_nav_bar.dart';

/// Wraps the 5 main tabs (Home, Menu, Cart, Orders, Profile) behind one
/// persistent, animated bottom navigation bar using go_router's
/// StatefulShellRoute — each tab keeps its own scroll position / state
/// when switching, exactly like native tab bars on iOS and Android.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  /// Lets any screen (e.g. an empty-state "Browse Menu" button) switch
  /// tabs programmatically: `MainShell.switchTab(context, 1)`.
  static void switchTab(BuildContext context, int index) {
    final shell = context.findAncestorWidgetOfExactType<MainShell>();
    shell?.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = [
      NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home, label: l10n.navHome),
      NavItemData(icon: Icons.restaurant_menu_outlined, activeIcon: Icons.restaurant_menu, label: l10n.navMenu),
      NavItemData(icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag, label: l10n.navCart),
      NavItemData(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: l10n.navOrders),
      NavItemData(icon: Icons.person_outline, activeIcon: Icons.person, label: l10n.navProfile),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: LuxuryBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        items: items,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Tapping the already-active tab resets it to its root page.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
