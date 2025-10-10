import '../models/product.dart';

abstract class ProductSource {
  Future<List<Product>> fetchProducts({String? keyword});
  Future<Product> fetchById(String id);
}

class InMemoryProductSource implements ProductSource {
  final _items = List.generate(
      16,
      (i) => Product(
            id: 'p$i',
            title: '綠茶拿鐵 #$i',
            description: '嚴選茶葉與牛奶調和，風味清爽。',
            image: 'https://picsum.photos/seed/tea$i/600/400',
            price: 2.5 + i,
            gallery: List.generate(
                3, (g) => 'https://picsum.photos/seed/tea${i}g$g/800/600'),
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
