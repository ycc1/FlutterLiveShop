import '../models/product.dart';

abstract class ProductSource {
  Future<List<Product>> fetchProducts({String? keyword});
  Future<Product> fetchById(String id);
}

class InMemoryProductSource implements ProductSource {
  final _items = List.generate(
      20,
      (i) => Product(
            id: 'p$i',
            title: '精品咖啡 #$i',
            description: '風味豐富，口感層次分明。',
            imageUrl: 'https://picsum.photos/seed/coffee$i/800/600',
            price: 3 + i.toDouble(),
          ));
  @override
  Future<List<Product>> fetchProducts({String? keyword}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (keyword == null || keyword.isEmpty) return _items;
    return _items.where((e) => e.title.contains(keyword)).toList();
  }

  @override
  Future<Product> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _items.firstWhere((e) => e.id == id);
  }
}
