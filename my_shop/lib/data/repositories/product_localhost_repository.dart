import 'dart:convert';
import '../models/product.dart';
import '../sources/product_source.dart';
import '../network/api_client.dart';

class ProductRepository_V1 {
  final ProductSource source;
  ProductRepository_V1(this.source);
  Future<List<Product>> list({String? keyword}) =>
      source.fetchProducts(keyword: keyword);
  Future<Product> byId(String id) => source.fetchById(id);
}
