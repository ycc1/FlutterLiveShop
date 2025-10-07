import '../sources/cart_source.dart';
class CartRepository {
  final CartSource source;
  CartRepository(this.source);
  Future<void> add(String id, int qty) => source.add(id, qty);
  Future<void> remove(String id) => source.remove(id);
  Future<void> clear() => source.clear();
  Future<Map<String,int>> snapshot() => source.snapshot();
}
