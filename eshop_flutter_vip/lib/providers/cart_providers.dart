import 'package:eshop_flutter_vip/providers/product_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_item.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/sources/cart_source.dart';

final cartSourceProvider = Provider<CartSource>((ref) => InMemoryCartSource());
final cartRepoProvider = Provider<CartRepository>(
    (ref) => CartRepository(ref.read(cartSourceProvider)));

class CartState extends StateNotifier<List<CartItem>> {
  final CartRepository repo;
  final ProductRepository productRepo;
  CartState(this.repo, this.productRepo) : super(const []) {
    refresh();
  }
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
    await repo.add(id, qty);
    await refresh();
  }

  Future<void> remove(String id) async {
    await repo.remove(id);
    await refresh();
  }

  Future<void> clear() async {
    await repo.clear();
    await refresh();
  }

  double get total => state.fold(0, (sum, it) => sum + it.subtotal);
}

final cartStateProvider =
    StateNotifierProvider<CartState, List<CartItem>>((ref) {
  final cartRepo = ref.read(cartRepoProvider);
  final productRepo = ref.read(productRepoProvider);
  return CartState(cartRepo, productRepo);
});
