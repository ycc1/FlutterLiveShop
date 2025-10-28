// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/login_page.dart';
import 'features/catalog/catalog_page.dart';
import 'features/checkout/checkout_page.dart';
import 'features/checkout/order_model.dart';
import 'features/checkout/order_qr_page.dart';
import 'features/minigame/game_main_page.dart';
import 'features/minigame/myGame/bingo/bingo_main_page.dart';
import 'features/minigame/myGame/bomb/bomb_defuse_page.dart';
import 'features/minigame/myGame/eTamagotchi/e_pet_page.dart';
import 'features/minigame/myGame/maze/maze_game_page.dart';
import 'features/product_detail/product_detail_page.dart';
import 'features/cart/cart_page.dart';
import 'features/profile/Setting/setting_page.dart';
import 'features/profile/VIP/vip_page.dart';
import 'features/profile/profile_page.dart';
import 'features/live/live_page.dart';
import 'features/recharge/recharge_page.dart';

import 'providers/auth_providers.dart';
import 'app_router_refresh.dart'; // ← 新增

final _rootKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshListenableProvider);
  final auth = ref.watch(authProvider);

  // 哪些路由需要登入
  bool _requiresAuth(String location) {
    return location.startsWith('/profile') ||
        location.startsWith('/checkout') ||
        location.startsWith('/orders') ||
        location.startsWith('/settings');
  }

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: refreshListenable, // ← 关键：当 auth 变更时重算 redirect
    redirect: (context, state) {
      final isLoggedIn = auth.isSignedIn;
      final loggingIn = state.uri.path == '/login';
      final loc = state.uri.toString(); // 包含完整 URL

      // 未登入访问受保护页面 → 去 /login?from=<原路径>
      if (!isLoggedIn && _requiresAuth(loc)) {
        final from = Uri.encodeComponent(loc);
        return '/login?from=$from';
      }

      // 已登入却在登录页 → 回跳到 from 或首页
      if (isLoggedIn && loggingIn) {
        final from = state.uri.queryParameters['from'];
        return from ?? '/';
      }

      return null;
    },

    routes: [
      // 底部5分支（商城 / 直播 / 充值 / 小游戏 / 我的）
      StatefulShellRoute.indexedStack(
        branches: [
          // 商城
          StatefulShellBranch(
            initialLocation: '/',
            routes: [
              GoRoute(path: '/', builder: (_, __) => const CatalogPage()),
            ],
          ),
          // 直播
          StatefulShellBranch(
            initialLocation: '/live',
            routes: [
              GoRoute(path: '/live', builder: (_, __) => const LivePage()),
            ],
          ),
          // 充值
          StatefulShellBranch(
            initialLocation: '/deposit',
            routes: [
              GoRoute(
                  path: '/deposit', builder: (_, __) => const RechargePage()),
            ],
          ),
          // 小游戏
          StatefulShellBranch(
            initialLocation: '/game',
            routes: [
              GoRoute(path: '/game', builder: (_, __) => const GameMainPage()),
            ],
          ),
          // 我的（受保护：实际由 redirect 控制）
          StatefulShellBranch(
            initialLocation: '/profile',
            routes: [
              GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfilePage()),
            ],
          ),
        ],
        builder: (context, state, navShell) {
          // 分支有 5 个 → 索引 0..4
          final safeIndex = navShell.currentIndex.clamp(0, 4);
          return Scaffold(
            body: navShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: safeIndex,
              onDestinationSelected: (index) =>
                  navShell.goBranch(index, initialLocation: false),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.storefront_outlined), label: '商城'),
                NavigationDestination(
                    icon: Icon(Icons.live_tv_outlined), label: '直播'),
                NavigationDestination(
                    icon: Icon(Icons.monetization_on), label: '充值'),
                NavigationDestination(icon: Icon(Icons.games), label: '小游戏'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline), label: '我的'),
              ],
            ),
          );
        },
      ),

      // 其余独立路由（不要放进 StatefulShellRoute）
      GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutPage()),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(
          from: state.uri.queryParameters['from'], // ← 传入来源
        ),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingPage()),
      GoRoute(path: '/vip', builder: (_, __) => const VipPage()),
      GoRoute(path: '/minigame/maze', builder: (_, __) => const MazeGamePage()),
      GoRoute(
          path: '/minigame/bomb', builder: (_, __) => const BombDefusePage()),
      GoRoute(
          path: '/minigame/eTamagotchi',
          builder: (_, __) => const EPetTamagotchiPage()),
      GoRoute(
          path: '/minigame/bingo', builder: (_, __) => const BingoMainPage()),
      GoRoute(
        path: '/orderQR',
        builder: (context, state) {
          final data = state.extra as OrderCreateResponse;
          return OrderQrPage(order: data);
        },
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product_detail',
        builder: (_, state) =>
            ProductDetailPage(id: state.pathParameters['id']!),
      ),
    ],
  );
});
