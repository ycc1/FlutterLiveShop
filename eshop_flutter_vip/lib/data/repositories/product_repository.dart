import '../models/product.dart';
import '../sources/product_source.dart';
class ProductRepository {
  final ProductSource source;
  ProductRepository(this.source);
  Future<List<Product>> list({String? keyword}) => source.fetchProducts(keyword: keyword);
  Future<Product> byId(String id) => source.fetchById(id);
}
