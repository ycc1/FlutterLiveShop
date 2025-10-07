import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_providers.dart';
import 'widgets/product_card.dart';
import 'widgets/search_bar.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({Key? key}) : super(key: key);
  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  String keyword = '';
  @override
  Widget build(BuildContext context) {
    final asyncProducts =
        ref.watch(productListProvider(keyword.isEmpty ? null : keyword));
    return Scaffold(
      appBar: AppBar(title: const Text('商城'), actions: [
        IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart')),
        IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile')),
        IconButton(
            icon: const Icon(Icons.live_tv_outlined),
            onPressed: () => context.push('/live')),
      ]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            CatalogSearchBar(onChanged: (v) => setState(() => keyword = v)),
            const SizedBox(height: 12),
            Expanded(
                child: asyncProducts.when(
              data: (items) => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12),
                itemCount: items.length,
                itemBuilder: (_, i) => ProductCard(
                    product: items[i],
                    onTap: () => context.push('/product/${items[i].id}')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('載入失敗：$e')),
            ))
          ]),
        ),
      ),
    );
  }
}
