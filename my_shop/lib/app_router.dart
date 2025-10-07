import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/login_page.dart';
import 'features/catalog/catalog_page.dart';
import 'features/checkout/checkout_page.dart';
import 'features/product_detail/product_detail_page.dart';
import 'features/cart/cart_page.dart';
import 'features/profile/profile_page.dart';
import 'features/live/live_page.dart';
import 'features/recharge/recharge_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: navigationShell.goBranch,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.storefront_outlined), label: '商城'),
              NavigationDestination(
                  icon: Icon(Icons.live_tv_outlined), label: '直播'),
              NavigationDestination(
                  icon: Icon(Icons.monetization_on), label: '充值'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline), label: '我的'),
            ],
          ),
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (context, state) => const CatalogPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/live', builder: (context, state) => const LivePage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/deposit',
                builder: (context, state) => const RechargePage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/cart', builder: (context, state) => const CartPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/checkout',
                builder: (context, state) => const CheckoutPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/login', builder: (context, state) => const LoginPage())
          ])
        ],
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product_detail',
        builder: (context, state) =>
            ProductDetailPage(id: state.pathParameters['id']!),
      ),
    ],
  );
});
