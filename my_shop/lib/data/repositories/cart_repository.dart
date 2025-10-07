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
