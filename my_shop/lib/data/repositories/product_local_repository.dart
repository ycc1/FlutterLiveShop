import 'dart:convert';
import '../models/product.dart';
import '../sources/product_source.dart';
import '../network/api_client.dart';

class ProductLocalRepository {
  final ProductSource source;
  ProductLocalRepository(this.source);
  Future<List<Product>> list({String? keyword}) =>
      source.fetchProducts(keyword: keyword);
  Future<Product> byId(String id) => source.fetchById(id);
}
