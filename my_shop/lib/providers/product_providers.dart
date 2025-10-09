import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/product_repository.dart';
import '../data/sources/product_source.dart';
import '../data/network/api_client.dart';

/*
final productSourceProvider = Provider<ProductSource>((ref) => InMemoryProductSource());
final productRepoProvider = Provider<ProductRepository>((ref) => ProductRepository(ref.read(productSourceProvider)));

final productListProvider = FutureProvider.family.autoDispose((ref, String? keyword) {
  final repo = ref.read(productRepoProvider);
  return repo.list(keyword: keyword);
});
*/

/// 查詢條件封裝類
class ProductQuery {
  final int page;
  final int pageSize;
  final int limit;
  final String? keyword;

  const ProductQuery({
    this.page = 1,
    this.pageSize = 20,
    this.limit = 100,
    this.keyword,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductQuery &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.keyword == keyword;
  }

  @override
  int get hashCode => Object.hash(page, pageSize, keyword);
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: 'http://localhost:2015'); // ← 改成你的 API Host
});

final productRepoProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.read(apiClientProvider));
});

/// 列表（带查询条件）
final productListProvider = FutureProvider.family.autoDispose(
  (ref, ProductQuery query) async {
    final repo = ref.read(productRepoProvider);
    final res = await repo.list(
      page: query.page,
      pageSize: query.pageSize,
      keyword: query.keyword,
    );
    return res;
  },
);

/// 详情
final productDetailProvider = FutureProvider.family
    .autoDispose((ref, String id) => ref.read(productRepoProvider).byId(id));
