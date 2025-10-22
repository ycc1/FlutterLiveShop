// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/login_page.dart';
import 'features/catalog/catalog_page.dart';
import 'features/checkout/checkout_page.dart';
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

// 顶层（可选）NavigatorKey
final _rootKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/', // 全局默认路径
    routes: [
      // 只保留“有底部 Tab 的 4 个分支”
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
          // 我的
          StatefulShellBranch(
            initialLocation: '/profile',
            routes: [
              GoRoute(
                  path: '/profile', builder: (_, __) => const ProfilePage()),
            ],
          ),
        ],
        builder: (context, state, navShell) {
          // 防止 selectedIndex 越界
          final safeIndex = navShell.currentIndex.clamp(0, 3);
          // 调试打印（可留可删）
          // print('🔹 currentIndex=${navShell.currentIndex} fullPath=${state.fullPath}');

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

      // ✅ 这些不要放在 StatefulShellRoute 里，否则会多出分支数量
      GoRoute(
        path: '/cart',
        builder: (_, __) => const CartPage(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, __) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingPage(),
      ),
      GoRoute(
        path: '/vip',
        builder: (_, __) => const VipPage(),
      ),
      GoRoute(
        path: '/minigame/maze',
        builder: (_, __) => const MazeGamePage(),
      ),
      GoRoute(
        path: '/minigame/bomb',
        builder: (_, __) => const BombDefusePage(),
      ),
      GoRoute(
        path: '/minigame/eTamagotchi',
        builder: (_, __) => const EPetTamagotchiPage(),
      ),
      GoRoute(
        path: '/minigame/bingo',
        builder: (_, __) => const BingoMainPage(),
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
