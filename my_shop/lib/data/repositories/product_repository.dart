import 'dart:convert';
import '../models/product.dart';
import '../sources/product_source.dart';
import '../network/api_client.dart';

/*
class ProductRepository {
  final ProductSource source;
  ProductRepository(this.source);
  Future<List<Product>> list({String? keyword}) =>
      source.fetchProducts(keyword: keyword);
  Future<Product> byId(String id) => source.fetchById(id);
}
*/
class PagedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final int limit;
  PagedResult(this.items, this.total, this.page, this.pageSize, this.limit);
}

abstract class ProductRepository {
  Future<PagedResult<Product>> list({
    int page,
    int pageSize,
    int limit,
    String? keyword,
  });

  Future<Product> byId(String id);
}

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient api;
  ProductRepositoryImpl(this.api);

  @override
  Future<PagedResult<Product>> list({
    int page = 1,
    int pageSize = 20,
    int limit = 100,
    String? keyword,
  }) async {
    // ✅ 改为 POST 请求
    final res = await api.post<String>(
      '/api/Agent/GetGoodsPageList',
      data: {
        'page': page,
        'pageSize': pageSize,
        'limit': limit,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
    );

    final body = res.data;
    if (body == null) {
      return PagedResult<Product>(const [], 0, page, pageSize, limit);
    }

    final dynamic json = jsonDecode(body);

    List listData;
    int total = 0;

    // ✅ 兼容不同的 .NET 返回格式
    if (json is Map) {
      final data = json['data'] ?? json['Data'] ?? json;
      listData =
          (data['items'] ?? data['list'] ?? data['rows'] ?? data ?? []) as List;
      total = (data['total'] ?? data['count'] ?? listData.length) as int;
    } else if (json is List) {
      listData = json;
      total = listData.length;
    } else {
      listData = const [];
    }

    final items = listData
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return PagedResult<Product>(items, total, page, pageSize, limit);
  }

  @override
  Future<Product> byId(String id) async {
    // ✅ 如果后端有详情接口，改成：
    // final res = await api.post<String>('/api/Agent/GetGoodsDetail', data: {'id': id});
    // final json = jsonDecode(res.data!);
    // return Product.fromJson(json['data'] ?? json);

    // 没有详情接口则从列表模拟取一笔
    final page = await list(page: 1, pageSize: 100);
    final found = page.items.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Product($id) not found'),
    );
    return found;
  }
}
