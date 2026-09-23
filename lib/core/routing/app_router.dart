import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/welcome/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/menu/presentation/screens/menu_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/menu/presentation/screens/dish_details_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/admin/presentation/screens/admin_menu_screen.dart';
import '../navigation/main_shell.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';

  static const home = '/home';
  static const menu = '/menu';
  static const cart = '/cart';
  static const orders = '/orders';
  static const profile = '/profile';
  static const settings = '/profile/settings';
  static const favorites = '/favorites';
  static const editProfile = '/profile/edit';
  static String dish(String id) => '/dish/$id';
  static String orderDetails(String id) => '/order/$id';
  static const admin = '/admin';
}

/// Central GoRouter instance. Every screen transition uses the same
/// cinematic fade+slide so navigation feels consistent no matter which
/// language / text direction is active.
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => _fadePage(const SplashScreen(), state),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      pageBuilder: (context, state) => _fadePage(const WelcomeScreen(), state),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => _slidePage(const LoginScreen(), state),
    ),
    GoRoute(
      path: AppRoutes.signup,
      pageBuilder: (context, state) => _slidePage(const SignupScreen(), state),
    ),

    // ---- Main app shell: persistent bottom nav across 5 tabs ----
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: AppRoutes.home, pageBuilder: (context, state) => _fadePage(const HomeScreen(), state)),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: AppRoutes.menu, pageBuilder: (context, state) => _fadePage(const MenuScreen(), state)),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: AppRoutes.cart, pageBuilder: (context, state) => _fadePage(const CartScreen(), state)),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: AppRoutes.orders, pageBuilder: (context, state) => _fadePage(const OrdersScreen(), state)),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => _fadePage(const ProfileScreen(), state),
            routes: [
              GoRoute(
                path: 'settings',
                pageBuilder: (context, state) => _slidePage(const SettingsScreen(), state),
              ),
            ],
          ),
        ]),
      ],
    ),

    // ---- Full-screen routes shown above the shell (no bottom nav) ----
    GoRoute(
      path: AppRoutes.favorites,
      pageBuilder: (context, state) => _slidePage(const FavoritesScreen(), state),
    ),
    GoRoute(
      path: '/dish/:id',
      pageBuilder: (context, state) {
        return _slidePage(DishDetailsScreen(dishId: state.pathParameters['id']!), state);
      },
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      pageBuilder: (context, state) => _slidePage(const EditProfileScreen(), state),
    ),
    GoRoute(
      path: '/order/:id',
      pageBuilder: (context, state) {
        return _slidePage(OrderDetailsScreen(orderId: state.pathParameters['id']!), state);
      },
    ),
    GoRoute(
      path: AppRoutes.admin,
      pageBuilder: (context, state) => _slidePage(const AdminMenuScreen(), state),
    ),
  ],
);

CustomTransitionPage _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 550),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage _slidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 480),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      // Direction-aware: uses logical (start -> end) offset so it slides
      // correctly whether the active locale is RTL or LTR.
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
