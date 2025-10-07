import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/catalog/catalog_page.dart';
import 'features/product_detail/product_detail_page.dart';
import 'features/cart/cart_page.dart';
import 'features/checkout/checkout_page.dart';
import 'features/profile/profile_page.dart';
import 'features/live/live_page.dart';
import 'features/auth/login_page.dart';
import 'providers/auth_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    redirect: (context, state) {
      final authed = ref.read(authProvider).isSignedIn;
      if (state.fullPath == '/checkout' && !authed) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const CatalogPage()),
      GoRoute(path: '/product/:id', builder: (_, s) => ProductDetailPage(id: s.pathParameters['id']!)),
      GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(path: '/live', builder: (_, __) => const LivePage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    ],
  );
});
