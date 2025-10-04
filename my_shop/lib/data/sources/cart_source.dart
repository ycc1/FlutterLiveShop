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