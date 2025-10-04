# FlutterLiveShop
這是一個使用 Flutter 建立的線上商城，預計完成的功能如下：「商品展示」、「直播平台」、「聊天室」、「購物車」、「小遊戲」、「積分活動」、「個人中心」、「客服」
# Flutter 電子商城骨架

> 功能涵蓋：商品展示、購物車、個人資訊、直播展示（HLS/MP4 示範），含 Riverpod 狀態管理、GoRouter 路由、抽象資料層、假資料與可替換的 API 介面。

---
# 文件結構（建議）
```
lib/
├─ main.dart
├─ app_router.dart
├─ theme/
│  └─ app_theme.dart
├─ core/
│  ├─ result.dart
│  ├─ exceptions.dart
│  └─ utils.dart
├─ data/
│  ├─ models/
│  │  ├─ product.dart
│  │  ├─ cart_item.dart
│  │  └─ user_profile.dart
│  ├─ sources/
│  │  ├─ product_source.dart
│  │  ├─ cart_source.dart
│  │  └─ user_source.dart
│  └─ repositories/
│     ├─ product_repository.dart
│     ├─ cart_repository.dart
│     └─ user_repository.dart
├─ providers/
│  ├─ product_providers.dart
│  ├─ cart_providers.dart
│  └─ user_providers.dart
└─ features/
   ├─ catalog/
   │  ├─ catalog_page.dart
   │  └─ widgets/
   │     ├─ product_card.dart
   │     └─ search_bar.dart
   ├─ product_detail/
   │  └─ product_detail_page.dart
   ├─ cart/
   │  └─ cart_page.dart
   ├─ profile/
   │  └─ profile_page.dart
   └─ live/
      ├─ live_page.dart
      └─ widgets/
         └─ live_video_player.dart
```

---
# pubspec.yaml（重點相依）
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.1
  cached_network_image: ^3.3.1
  intl: ^0.19.0
  video_player: ^2.9.1
  chewie: ^1.7.5  # 可切換播放控制
  # 如需 WebRTC 直播可改採 livekit_client / flutter_webrtc

dev_dependencies:
  flutter_lints: ^4.0.0
```

---
# lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'E‑Shop',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
```

---
# lib/app_router.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/catalog/catalog_page.dart';
import 'features/product_detail/product_detail_page.dart';
import 'features/cart/cart_page.dart';
import 'features/profile/profile_page.dart';
import 'features/live/live_page.dart';

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
              NavigationDestination(icon: Icon(Icons.storefront_outlined), label: '商城'),
              NavigationDestination(icon: Icon(Icons.live_tv_outlined), label: '直播'),
              NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: '購物車'),
              NavigationDestination(icon: Icon(Icons.person_outline), label: '我的'),
            ],
          ),
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (context, state) => const CatalogPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/live', builder: (context, state) => const LivePage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/cart', builder: (context, state) => const CartPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfilePage())
          ]),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product_detail',
        builder: (context, state) => ProductDetailPage(id: state.pathParameters['id']!),
      ),
    ],
  );
});
```

---
# lib/theme/app_theme.dart
```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
      );
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF80CBC4),
        useMaterial3: true,
      );
}
```

---
# lib/core/result.dart
```dart
sealed class Result<T> {
  const Result();
  R when<R>({required R Function(T) ok, required R Function(Object, StackTrace?) err});
}
class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
  @override
  R when<R>({required R Function(T p1) ok, required R Function(Object, StackTrace?) err}) => ok(value);
}
class Err<T> extends Result<T> {
  final Object error;
  final StackTrace? st;
  const Err(this.error, [this.st]);
  @override
  R when<R>({required R Function(T p1) ok, required R Function(Object, StackTrace?) err}) => err(error, st);
}
```

---
# lib/core/exceptions.dart
```dart
class NetworkException implements Exception { final String message; NetworkException(this.message); }
class NotFoundException implements Exception { final String message; NotFoundException(this.message); }
```

---
# lib/data/models/product.dart
```dart
class Product {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final List<String> gallery;
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.gallery = const [],
  });
}
```

---
# lib/data/models/cart_item.dart
```dart
import 'product.dart';
class CartItem {
  final Product product;
  final int qty;
  const CartItem(this.product, this.qty);
  CartItem copyWith({int? qty}) => CartItem(product, qty ?? this.qty);
  double get subtotal => product.price * qty;
}
```

---
# lib/data/models/user_profile.dart
```dart
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatar;
  const UserProfile({required this.id, required this.name, required this.email, required this.avatar});
}
```

---
# lib/data/sources/product_source.dart（可切換 API / 假資料）
```dart
import '../models/product.dart';

abstract class ProductSource {
  Future<List<Product>> fetchProducts({String? keyword});
  Future<Product> fetchById(String id);
}

class InMemoryProductSource implements ProductSource {
  final _items = List.generate(16, (i) => Product(
    id: 'p$i',
    title: '綠茶拿鐵 #$i',
    description: '嚴選茶葉與牛奶調和，風味清爽。',
    imageUrl: 'https://picsum.photos/seed/tea$i/600/400',
    price: 2.5 + i,
    gallery: List.generate(3, (g) => 'https://picsum.photos/seed/tea${i}g$g/800/600'),
  ));
  @override
  Future<List<Product>> fetchProducts({String? keyword}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (keyword == null || keyword.isEmpty) return _items;
    return _items.where((e) => e.title.contains(keyword)).toList();
  }
  @override
  Future<Product> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _items.firstWhere((e) => e.id == id);
  }
}
```

---
# lib/data/sources/cart_source.dart
```dart
import '../models/product.dart';

abstract class CartSource {
  Future<void> add(Product p, int qty);
  Future<void> remove(String productId);
  Future<void> clear();
  Future<Map<String, int>> snapshot();
}

class InMemoryCartSource implements CartSource {
  final Map<String, int> _map = {};
  @override
  Future<void> add(Product p, int qty) async { _map.update(p.id, (v) => v + qty, ifAbsent: () => qty); }
  @override
  Future<void> remove(String productId) async { _map.remove(productId); }
  @override
  Future<void> clear() async { _map.clear(); }
  @override
  Future<Map<String, int>> snapshot() async => Map.unmodifiable(_map);
}
```

---
# lib/data/sources/user_source.dart
```dart
import '../models/user_profile.dart';

abstract class UserSource { Future<UserProfile> me(); }
class DummyUserSource implements UserSource {
  @override
  Future<UserProfile> me() async => const UserProfile(
    id: 'u1', name: 'Alice', email: 'alice@example.com', avatar: 'https://i.pravatar.cc/150?img=32');
}
```

---
# lib/data/repositories/product_repository.dart
```dart
import '../models/product.dart';
import '../sources/product_source.dart';

class ProductRepository {
  final ProductSource source;
  ProductRepository(this.source);
  Future<List<Product>> list({String? keyword}) => source.fetchProducts(keyword: keyword);
  Future<Product> byId(String id) => source.fetchById(id);
}
```

---
# lib/data/repositories/cart_repository.dart
```dart
import '../models/product.dart';
import '../sources/cart_source.dart';

class CartRepository {
  final CartSource source;
  CartRepository(this.source);
  Future<void> add(Product p, int qty) => source.add(p, qty);
  Future<void> remove(String id) => source.remove(id);
  Future<void> clear() => source.clear();
  Future<Map<String, int>> snapshot() => source.snapshot();
}
```

---
# lib/data/repositories/user_repository.dart
```dart
import '../models/user_profile.dart';
import '../sources/user_source.dart';

class UserRepository {
  final UserSource source;
  UserRepository(this.source);
  Future<UserProfile> me() => source.me();
}
```

---
# lib/providers/product_providers.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/product_repository.dart';
import '../data/sources/product_source.dart';

final productSourceProvider = Provider<ProductSource>((ref) => InMemoryProductSource());
final productRepoProvider = Provider<ProductRepository>((ref) => ProductRepository(ref.read(productSourceProvider)));

final productListProvider = FutureProvider.family.autoDispose((ref, String? keyword) {
  final repo = ref.read(productRepoProvider);
  return repo.list(keyword: keyword);
});
```

---
# lib/providers/cart_providers.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_item.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/sources/cart_source.dart';

final cartSourceProvider = Provider<CartSource>((ref) => InMemoryCartSource());
final cartRepoProvider = Provider<CartRepository>((ref) => CartRepository(ref.read(cartSourceProvider)));

class CartState extends StateNotifier<List<CartItem>> {
  final CartRepository repo;
  final ProductRepository productRepo;
  CartState(this.repo, this.productRepo) : super(const []);

  Future<void> refresh() async {
    final map = await repo.snapshot();
    final items = <CartItem>[];
    for (final e in map.entries) {
      final p = await productRepo.byId(e.key);
      items.add(CartItem(p, e.value));
    }
    state = items;
  }

  Future<void> add(String id, {int qty = 1}) async {
    final p = await productRepo.byId(id);
    await repo.add(p, qty);
    await refresh();
  }

  Future<void> remove(String id) async { await repo.remove(id); await refresh(); }
  Future<void> clear() async { await repo.clear(); await refresh(); }
  double get total => state.fold(0, (sum, it) => sum + it.subtotal);
}

final cartStateProvider = StateNotifierProvider<CartState, List<CartItem>>((ref) {
  final cartRepo = ref.read(cartRepoProvider);
  final productRepo = ref.read(Provider((_) => ref.read(productRepoProvider)));
  final st = CartState(cartRepo, productRepo);
  st.refresh();
  return st;
});
```

---
# lib/providers/user_providers.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/user_repository.dart';
import '../data/sources/user_source.dart';

final userSourceProvider = Provider<UserSource>((ref) => DummyUserSource());
final userRepoProvider = Provider<UserRepository>((ref) => UserRepository(ref.read(userSourceProvider)));
final meProvider = FutureProvider((ref) => ref.read(userRepoProvider).me());
```

---
# lib/features/catalog/widgets/product_card.dart
```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard({super.key, required this.product, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(onTap: onTap, child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.cover)),
          Padding(padding: const EdgeInsets.all(12), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
            ],
          )),
        ],
      )),
    );
  }
}
```

---
# lib/features/catalog/widgets/search_bar.dart
```dart
import 'package:flutter/material.dart';

class CatalogSearchBar extends StatefulWidget {
  final void Function(String) onChanged;
  const CatalogSearchBar({super.key, required this.onChanged});
  @override
  State<CatalogSearchBar> createState() => _CatalogSearchBarState();
}
class _CatalogSearchBarState extends State<CatalogSearchBar> {
  final controller = TextEditingController();
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: '搜尋商品',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: widget.onChanged,
    );
  }
}
```

---
# lib/features/catalog/catalog_page.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_providers.dart';
import 'widgets/product_card.dart';
import 'widgets/search_bar.dart';
import 'package:go_router/go_router.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});
  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  String keyword = '';
  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productListProvider(keyword.isEmpty ? null : keyword));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CatalogSearchBar(onChanged: (v){ setState(()=> keyword = v); }),
            const SizedBox(height: 12),
            Expanded(child: asyncProducts.when(
              data: (items) => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .70, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: items.length,
                itemBuilder: (_, i) => ProductCard(product: items[i], onTap: () => context.push('/product/${items[i].id}')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('載入失敗：$e')),
            )),
          ],
        ),
      ),
    );
  }
}
```

---
# lib/features/product_detail/product_detail_page.dart
```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_providers.dart';
import '../../providers/cart_providers.dart';

class ProductDetailPage extends ConsumerWidget {
  final String id;
  const ProductDetailPage({super.key, required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(productRepoProvider);
    return FutureBuilder(
      future: repo.byId(id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final p = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(p.title)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AspectRatio(
                aspectRatio: 4/3,
                child: CachedNetworkImage(imageUrl: p.imageUrl, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('\$${p.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(p.description),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: p.gallery.map((g) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(imageUrl: g, width: 100, height: 100, fit: BoxFit.cover),
              )).toList()),
            ],
          ),
          bottomNavigationBar: SafeArea(child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () => ref.read(cartStateProvider.notifier).add(p.id),
              label: const Text('加入購物車'),
            ),
          )),
        );
      },
    );
  }
}
```

---
# lib/features/cart/cart_page.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_providers.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('購物車')),
      body: items.isEmpty
          ? const Center(child: Text('購物車是空的'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) => ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(items[i].product.imageUrl)),
                title: Text(items[i].product.title),
                subtitle: Text('x${items[i].qty}'),
                trailing: Text('\$${items[i].subtotal.toStringAsFixed(2)}'),
                onLongPress: () => ref.read(cartStateProvider.notifier).remove(items[i].product.id),
              )),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: Text('合計：\$${ref.read(cartStateProvider.notifier).total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge)),
              FilledButton(onPressed: () {}, child: const Text('結帳')),
            ],
          ),
        ),
      ),
    );
  }
}
```

---
# lib/features/profile/profile_page.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: meAsync.when(
        data: (me) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(me.avatar), radius: 28),
              title: Text(me.name), subtitle: Text(me.email),
            ),
            const Divider(),
            const ListTile(leading: Icon(Icons.location_on_outlined), title: Text('地址管理')),
            const ListTile(leading: Icon(Icons.receipt_long_outlined), title: Text('訂單記錄')),
            const ListTile(leading: Icon(Icons.settings_outlined), title: Text('設定')),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('載入失敗：$e')),
      ),
    );
  }
}
```

---
# lib/features/live/widgets/live_video_player.dart
```dart
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LiveVideoPlayer extends StatefulWidget {
  final String url; // HLS(.m3u8) 或 MP4 皆可
  const LiveVideoPlayer({super.key, required this.url});
  @override
  State<LiveVideoPlayer> createState() => _LiveVideoPlayerState();
}

class _LiveVideoPlayerState extends State<LiveVideoPlayer> {
  late final VideoPlayerController _ctrl;
  ChewieController? _chewie;
  @override
  void initState() {
    super.initState();
    _ctrl = widget.url.endsWith('.m3u8')
        ? VideoPlayerController.networkUrl(Uri.parse(widget.url), httpHeaders: const {})
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _ctrl.initialize().then((_) {
      _chewie = ChewieController(videoPlayerController: _ctrl, autoPlay: true, looping: true);
      setState(() {});
    });
  }
  @override
  void dispose() { _chewie?.dispose(); _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (_chewie == null || !_ctrl.value.isInitialized) {
      return const AspectRatio(aspectRatio: 16/9, child: Center(child: CircularProgressIndicator()));
    }
    return AspectRatio(aspectRatio: _ctrl.value.aspectRatio, child: Chewie(controller: _chewie!));
  }
}
```

---
# lib/features/live/live_page.dart
```dart
import 'package:flutter/material.dart';
import 'widgets/live_video_player.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});
  @override
  Widget build(BuildContext context) {
    // Demo 用公用串流；正式環境建議採 HLS/LL-HLS 或 WebRTC（如 LiveKit）
    const demoUrl = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
    return Scaffold(
      appBar: AppBar(title: const Text('直播')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          LiveVideoPlayer(url: demoUrl),
          SizedBox(height: 12),
          Text('直播間介紹：這裡可展示商品、聊天室、點讚動畫等擴充組件。'),
        ],
      ),
    );
  }
}
```

---
# 說明與擴充點
- **API 替換**：`sources/` 目前為 InMemory，可替換為 REST / GraphQL / gRPC。
- **身分驗證**：可加入 Firebase Auth / 自建 JWT；UserSource 換成遠端。
- **購物流程**：加入下單、付款頁與地址管理。
- **直播互動**：整合聊天（SignalR/Socket.IO）、點讚、商品掛載（浮層卡片）。
- **國際化**：接入 `intl` 與 `flutter_localizations`。
- **狀態持久化**：Riverpod 與 `shared_preferences` 或 `hydrated_riverpod`。
- **主題/品牌**：`AppTheme` 可改色票、字體、圓角。

---
# 執行
1. `flutter pub get`
2. `flutter run`

> 這是一個可直接跑的骨架。你可以逐步把資料來源替換為真實後端、加上聊天室與下單付款流程。
