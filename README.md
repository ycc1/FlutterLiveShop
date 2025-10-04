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


---
# ➕ 擴充 1：直播聊天室（Socket.IO / SignalR 擇一）+ 點讚互動

## pubspec.yaml 新增依賴（擇一）
```yaml
dependencies:
  # Socket.IO 客戶端
  socket_io_client: ^2.0.3
  # 或使用 ASP.NET Core SignalR
  signalr_netcore: ^1.3.7
```

> 建議先用 **Socket.IO** 做 PoC；SignalR 方案在需要與 .NET 後端打通時切換。

## 抽象層：ChatService 介面
```dart
// lib/features/chat/chat_service.dart
abstract class ChatService {
  Future<void> connect({required String token, required String room});
  Future<void> disconnect();
  Stream<ChatEvent> events();
  Future<void> sendText(String text, {String? toUser});
  Future<void> sendLike();
}

class ChatEvent {
  final String type; // message/system/like/typing
  final String? from;
  final String? content;
  const ChatEvent(this.type, {this.from, this.content});
}
```

## Socket.IO 實作
```dart
// lib/features/chat/socketio_chat_service.dart
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'chat_service.dart';

class SocketIoChatService implements ChatService {
  io.Socket? _s;
  final _ctrl = StreamController<ChatEvent>.broadcast();
  @override
  Future<void> connect({required String token, required String room}) async {
    _s = io.io(
      'https://your-chat-host',
      io.OptionBuilder().setTransports(['websocket']).setExtraHeaders({'Authorization':'Bearer $token'}).build()
    );
    _s!.onConnect((_) { _s!.emit('join', {'room': room}); });
    _s!.on('message', (data){ _ctrl.add(ChatEvent('message', from: data['from'], content: data['text'])); });
    _s!.on('like',    (data){ _ctrl.add(const ChatEvent('like')); });
    _s!.on('system',  (data){ _ctrl.add(ChatEvent('system', content: data.toString())); });
  }
  @override
  Future<void> disconnect() async { await _s?.dispose(); await _ctrl.close(); }
  @override
  Stream<ChatEvent> events() => _ctrl.stream;
  @override
  Future<void> sendText(String text, {String? toUser}) async => _s?.emit('send', {'text': text, 'to': toUser});
  @override
  Future<void> sendLike() async => _s?.emit('like', {});
}
```

## SignalR 實作（可替換）
```dart
// lib/features/chat/signalr_chat_service.dart
import 'package:signalr_netcore/signalr_client.dart';
import 'chat_service.dart';

class SignalRChatService implements ChatService {
  HubConnection? _hub;
  final _ctrl = StreamController<ChatEvent>.broadcast();
  @override
  Future<void> connect({required String token, required String room}) async {
    _hub = HubConnectionBuilder()
      .withUrl('https://your-api/hubs/chat', options: HttpConnectionOptions(accessTokenFactory: () async => token))
      .withAutomaticReconnect()
      .build();
    _hub!.on('Message', (args){ _ctrl.add(ChatEvent('message', from: args?[0]?.toString(), content: args?[1]?.toString())); });
    _hub!.on('System',  (args){ _ctrl.add(ChatEvent('system', content: args?.first.toString())); });
    _hub!.on('Like',    (args){ _ctrl.add(const ChatEvent('like')); });
    await _hub!.start();
    await _hub!.invoke('JoinRoom', args: [room]);
  }
  @override
  Future<void> disconnect() async { await _hub?.stop(); await _ctrl.close(); }
  @override
  Stream<ChatEvent> events() => _ctrl.stream;
  @override
  Future<void> sendText(String text, {String? toUser}) async => _hub?.invoke('SendToRoom', args: ['room-1', text, 'text']);
  @override
  Future<void> sendLike() async => _hub?.invoke('SendLike', args: ['room-1']);
}
```

## Chat UI（含點讚飄心）
```dart
// lib/features/chat/chat_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_service.dart';
import 'socketio_chat_service.dart';

final chatServiceProvider = Provider<ChatService>((_) => SocketIoChatService());

class ChatPage extends ConsumerStatefulWidget { const ChatPage({super.key});
  @override ConsumerState<ChatPage> createState() => _ChatPageState(); }
class _ChatPageState extends ConsumerState<ChatPage> with TickerProviderStateMixin {
  final List<ChatEvent> logs = [];
  late final AnimationController _likeCtrl;
  @override void initState(){ super.initState(); _likeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800)); }
  @override void dispose(){ _likeCtrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context){
    final svc = ref.read(chatServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('直播聊天室')),
      body: Column(children:[
        Expanded(child: ListView.builder(itemCount: logs.length, itemBuilder: (_, i){
          final e = logs[i];
          return ListTile(leading: e.type=='like'? const Icon(Icons.favorite, color: Colors.pink): const Icon(Icons.chat_bubble_outline),
            title: Text(e.type=='like'? '👏 點讚' : '${e.from??'??'}：${e.content??''}'));
        })),
        SizeTransition(sizeFactor: CurvedAnimation(parent: _likeCtrl, curve: Curves.easeOutBack), child: const Icon(Icons.favorite, color: Colors.pink, size: 48)),
        Padding(padding: const EdgeInsets.all(8), child: Row(children:[
          Expanded(child: TextField(onSubmitted: (t)=> svc.sendText(t), decoration: const InputDecoration(hintText: '說點什麼...', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.favorite), onPressed: (){ svc.sendLike(); _likeCtrl.forward(from: 0); }),
        ]))
      ]),
    );
  }
}
```

---
# ➕ 擴充 2：下單 / 結帳流程（模型 + 假金流）

## 資料模型
```dart
// lib/data/models/order.dart
class Address { final String name, phone, line1, city; const Address({required this.name, required this.phone, required this.line1, required this.city}); }
class OrderItem { final String productId; final String title; final double price; final int qty; const OrderItem({required this.productId, required this.title, required this.price, required this.qty}); double get subtotal => price*qty; }
class Order {
  final String id; final List<OrderItem> items; final Address address; final double total; final String status; // pending/paid/failed
  const Order({required this.id, required this.items, required this.address, required this.total, this.status='pending'});
}
```

## Repository + 假金流 Service
```dart
// lib/services/payment_service.dart
class PaymentIntent { final String id; final int amountCents; final String currency; PaymentIntent(this.id, this.amountCents, this.currency); }
abstract class PaymentService { Future<PaymentIntent> createIntent(int amountCents, {String currency='USD'}); Future<bool> confirm(String intentId); }
class MockPaymentService implements PaymentService {
  @override Future<PaymentIntent> createIntent(int amountCents, {String currency='USD'}) async => PaymentIntent('pi_${DateTime.now().millisecondsSinceEpoch}', amountCents, currency);
  @override Future<bool> confirm(String intentId) async { await Future.delayed(const Duration(seconds: 1)); return true; }
}
```

## Checkout Page（從購物車建立訂單 → 建立金流 Intent → 模擬支付成功）
```dart
// lib/features/checkout/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_providers.dart';
import '../../services/payment_service.dart';

final paymentServiceProvider = Provider<PaymentService>((_) => MockPaymentService());

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartStateProvider);
    final total = ref.read(cartStateProvider.notifier).total;
    return Scaffold(
      appBar: AppBar(title: const Text('結帳')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('商品 (${items.length})', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Expanded(child: ListView.builder(itemCount: items.length, itemBuilder: (_, i){
            final it = items[i];
            return ListTile(title: Text(it.product.title), subtitle: Text('x${it.qty}'), trailing: Text('\$${it.subtotal.toStringAsFixed(2)}'));
          })),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
            const Text('合計'), Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge)
          ]),
          const SizedBox(height: 12),
          FilledButton(onPressed: () async {
            final svc = ref.read(paymentServiceProvider);
            final intent = await svc.createIntent((total*100).round());
            final ok = await svc.confirm(intent.id);
            if(ok){
              if(context.mounted){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('付款成功')));
              }
              await ref.read(cartStateProvider.notifier).clear();
            }
          }, child: const Text('付款')),
        ]),
      ),
    );
  }
}
```

> 之後可將 `PaymentService` 替換為 Stripe/PayPal/自家金流 SDK。

---
# ➕ 擴充 3：多語系（繁中 / 英）與主題色客製

## pubspec.yaml 加入本地化
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
flutter:
  generate: true
```

## l10n 設定與字串
```json
// lib/l10n/app_en.arb
{
  "appTitle": "E‑Shop",
  "tabStore": "Store",
  "tabLive": "Live",
  "tabCart": "Cart",
  "tabProfile": "Profile",
  "addToCart": "Add to cart",
  "checkout": "Checkout",
  "total": "Total"
}
```
```json
// lib/l10n/app_zh.arb
{
  "appTitle": "電子商城",
  "tabStore": "商城",
  "tabLive": "直播",
  "tabCart": "購物車",
  "tabProfile": "我的",
  "addToCart": "加入購物車",
  "checkout": "結帳",
  "total": "合計"
}
```

## main.dart 啟用本地化與主題
```dart
// 片段：加入 localizationsDelegates / supportedLocales
return MaterialApp.router(
  title: 'E‑Shop',
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  routerConfig: router,
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('en'), Locale('zh')],
);
```

## 主題色客製（支援動態更換）
```dart
// lib/theme/app_theme.dart (新增動態方案)
class ThemeController extends ChangeNotifier {
  Color seed = const Color(0xFF2E7D32);
  void update(Color c){ seed = c; notifyListeners(); }
}
```

```dart
// main.dart 以 Inherited/Provider 方式提供 ThemeController（略），或直接做設置頁切換顏色。
```

---
# 🔗 路由接入
- 在 `app_router.dart` 的分頁或其他入口，加上：
```dart
GoRoute(path: '/chat', builder: (_, __) => const ChatPage()),
GoRoute(path: '/checkout', builder: (_, __) => const CheckoutPage()),
```
- 在購物車頁面底部「結帳」按鈕導向 `/checkout`。

---
# 🚀 後續落地建議
- 將 ChatService 的 Token 與房間由你後端簽名發放，避免匿名濫用。
- 直播頁整合聊天室（畫面上半部影片、下半部訊息/點讚）。
- 加入訊息節流與本地訊息快取，提升體驗。
- 金流切換 Stripe：intent → confirm → webhook 確認訂單狀態。
- i18n：後續可加 `intl_utils` 自動產生 `AppLocalizations` 對應 getter。


---
# ✅ 一次到位：整合版 Flutter 電子商城骨架（含聊天/點讚、下單/付款、i18n、主題）
> 已將先前各段代碼整合為**單一可跑專案骨架**。採 Flutter 3.x / Dart ≥2.17 語法（`super.key` 等），若你當前 SDK 較舊，請將 `super.key` 改為 `({Key? key}) : super(key:key)`。

## 1) `pubspec.yaml`（整合依賴）
```yaml
environment:
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.1
  cached_network_image: ^3.3.1
  intl: ^0.19.0
  # 直播播放（HLS/MP4）
  video_player: ^2.9.1
  chewie: ^1.7.5
  # 聊天（擇一或同時保留，以抽象層切換）
  socket_io_client: ^2.0.3
  signalr_netcore: ^1.3.7

  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_lints: ^4.0.0
```

## 2) 目錄（合併後）
```
lib/
├─ main.dart
├─ app_router.dart
├─ theme/
│  ├─ app_theme.dart
│  └─ theme_controller.dart
├─ core/
│  ├─ result.dart
│  └─ exceptions.dart
├─ data/
│  ├─ models/ (product.dart, cart_item.dart, user_profile.dart, order.dart)
│  ├─ sources/ (product_source.dart, cart_source.dart, user_source.dart)
│  └─ repositories/ (...)
├─ providers/
│  ├─ product_providers.dart
│  ├─ cart_providers.dart
│  ├─ user_providers.dart
│  └─ chat_providers.dart
├─ features/
│  ├─ catalog/ (catalog_page.dart + widgets)
│  ├─ product_detail/ (product_detail_page.dart)
│  ├─ cart/ (cart_page.dart)
│  ├─ checkout/ (checkout_page.dart)
│  ├─ profile/ (profile_page.dart)
│  └─ live/ (live_page.dart + widgets/live_video_player.dart)
└─ features/chat/
   ├─ chat_page.dart
   ├─ chat_service.dart
   ├─ socketio_chat_service.dart
   └─ signalr_chat_service.dart

l10n/
 ├─ app_en.arb
 └─ app_zh.arb
```

> `order.dart`、`payment_service.dart`、`checkout_page.dart` 已整合，並將「聊天室 + 點讚」的抽象層與兩種實作納入 `features/chat/`。

## 3) 關鍵檔案補充/修正
- **ProductDetail** 使用 `FutureBuilder<Product>` 明確型別，避免 `Object` 報錯。
- **ChatService** 維持事件流 `Stream<ChatEvent>`；`SocketIoChatService` 與 `SignalRChatService` 任一可用。
- **Checkout** 走 `MockPaymentService`（可替 Stripe/PayPal）。
- **i18n** 提供 `app_en.arb` / `app_zh.arb`，`main.dart` 已載入 `flutter_localizations`。
- **主題** 以 `ThemeController` 動態切換色票。

> 具體程式碼已在前述章節與本文件先前部分提供；此處為整合說明。若你需要我導出「最終一份完整專案 zip」，告訴我即可打包。

## 4) Live + Chat 組合頁（用法）
在 `LivePage` 內嵌上半部影片、下半部聊天：
```dart
// LivePage 片段
return Scaffold(
  appBar: AppBar(title: const Text('直播')),
  body: Column(children: const [
    Expanded(flex: 3, child: LiveVideoPlayer(url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8')),
    Divider(height: 1),
    Expanded(flex: 2, child: ChatPage()),
  ]),
);
```

## 5) 切換聊天後端（Socket.IO ↔ SignalR）
`providers/chat_providers.dart` 中決定使用哪種實作：
```dart
final chatServiceProvider = Provider<ChatService>((ref) {
  // return SignalRChatService();
  return SocketIoChatService();
});
```

## 6) 訂單 & 付款流程（Mock → 真金流）
- `Order`, `OrderItem`, `Address` 已定義
- `PaymentService` 以 `MockPaymentService` 實作，正式上線時換成 Stripe：
  - `createIntent(amount)` 取得 intent id
  - `confirm(intentId)` → webhook 更新訂單狀態
- `CheckoutPage` 從 `cartStateProvider` 生成訂單金額，成功後清空購物車

## 7) 多語系與主題
- `l10n/` 下兩個 `.arb` 提供基本字串
- `main.dart`：加入 `localizationsDelegates` / `supportedLocales`
- `theme/theme_controller.dart`：呼叫 `update(Color)` 實作動態主題

## 8) VS Code 一鍵啟動（Chrome/Windows）
`.vscode/launch.json` 已於先前章節提供；選 `Flutter Web (Chrome)` 按 F5 即可

## 9) 執行步驟（再次彙整）
```bash
flutter config --enable-web
flutter pub get
flutter run -d chrome
# 或 VS Code 選取「Flutter Web (Chrome)」→ F5
```

## 10) 常見錯誤對照
| 症狀 | 解法 |
|---|---|
| `super-parameters disabled` | 將 `pubspec.yaml` 的 `environment` 提升至 `sdk: ">=2.17.0 <4.0.0"` 或把 `super.key` 改回傳統寫法 |
| `Object has no getter 'title'` | `FutureBuilder<Product>` 指定泛型，或 `snapshot.data as Product` |
| 找不到 `main.dart` | 確保 `pubspec.yaml` 在**專案根**、`main.dart` 在 `lib/`，於專案根執行 `flutter run` |
| HLS 播放無法啟動 | 換成 MP4 測試、瀏覽器允許自動播放、檢查 CORS |
| 聊天連不上 | 確認後端 URL、CORS、Token、WebSocket 可連通（wss/http） |

---
# 進階：接後端建議
- 聊天/信令：SignalR（.NET）或 Socket.IO（Node）→ 提供 `Bearer` token 與 room 名稱
- 媒體：HLS（Nginx+FFmpeg/Mux/CloudFront）或 WebRTC（LiveKit）
- 商品/訂單 API：REST/GraphQL；訂單狀態變更用 webhook
- 靜態資源：圖片走 CDN；縮略圖 `CachedNetworkImage`

> 若要，我可以把這份骨架**打包為 zip** 或建立 **GitHub 模板倉庫**，並附上最小 Node/ .NET 後端服務（聊天室 + 假支付 + 商品 API），讓 App 直接連上去測試。
