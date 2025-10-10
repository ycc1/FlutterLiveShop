import 'dart:convert';
import '../models/product.dart';
import '../network/api_client.dart';

class PagedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final int limit;
  PagedResult(this.items, this.total, this.page, this.pageSize,
      {this.limit = 100});
}

abstract class ProductRepository {
  Future<PagedResult<Product>> list({
    int page = 1,
    int pageSize = 20,
    String? keyword,
    int limit,
  });

  Future<Product> byId(String id);
}

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient api;
  ProductRepositoryImpl(this.api);

  /// 依 .NET 常见分页约定：page / pageSize / keyword（按你后端为准）
  /// 你的接口：/api/Agent/GetGoodsPageList
  @override
  Future<PagedResult<Product>> list({
    int page = 1,
    int pageSize = 20,
    int limit = 100,
    String? keyword,
  }) async {
    final res = await api.post<String>(
      '/api/Agent/GetGoodsPageList',
      data: {
        'page': page,
        'pageSize': pageSize,
        'limit': limit,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
    );

    // 假设返回结构可能是：
    // { "code": 0, "data": { "items": [...], "total": 123 } }
    // 或者直接是数组： [ ... ]
    final body = res.data;
    if (body == null) {
      return PagedResult<Product>(const [], 0, page, pageSize);
    }
    final dynamic json = jsonDecode(body);

    List listData;
    int total = 0;

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
    return PagedResult<Product>(items, total, page, pageSize);
  }

  /// 若后端没有单独的详情接口，这里先用列表里查找/或改为请求 /GetGoodsDetail?id=...
  @override
  Future<Product> byId(String id) async {
    // 如果后端已提供详情接口，改成：
    // final res = await api.get<String>('/api/Agent/GetGoodsDetail', query: {'id': id});
    // final json = jsonDecode(res.data!);
    // return Product.fromJson(json['data'] ?? json);

    // 没有详情接口就退而求其次：在第一页里找（或加大 pageSize）
    final page = await list(page: 1, pageSize: 100);
    final found = page.items.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Product($id) not found'),
    );
    return found;
  }
}
