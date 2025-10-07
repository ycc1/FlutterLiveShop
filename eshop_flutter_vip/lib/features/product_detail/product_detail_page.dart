import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_providers.dart';
import '../../providers/cart_providers.dart';
import '../../data/models/product.dart';

class ProductDetailPage extends ConsumerWidget {
  final String id;
  const ProductDetailPage({Key? key, required this.id}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(productRepoProvider);
    return FutureBuilder<Product>(
      future: repo.byId(id),
      builder: (context, snapshot){
        if(!snapshot.hasData){ return const Scaffold(body: Center(child: CircularProgressIndicator())); }
        final p = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(p.title)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AspectRatio(aspectRatio: 4/3, child: CachedNetworkImage(imageUrl: p.imageUrl, fit: BoxFit.cover)),
              const SizedBox(height: 12),
              Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('\$${p.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(p.description),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: ()=> ref.read(cartStateProvider.notifier).add(p.id),
                label: const Text('加入購物車'),
              ),
            ),
          ),
        );
      },
    );
  }
}
