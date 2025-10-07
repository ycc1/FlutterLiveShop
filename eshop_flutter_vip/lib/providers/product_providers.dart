import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/product_repository.dart';
import '../data/sources/product_source.dart';

final productSourceProvider = Provider<ProductSource>((ref)=> InMemoryProductSource());
final productRepoProvider = Provider<ProductRepository>((ref)=> ProductRepository(ref.read(productSourceProvider)));

final productListProvider = FutureProvider.family((ref, String? keyword){
  final repo = ref.read(productRepoProvider);
  return repo.list(keyword: keyword);
});
