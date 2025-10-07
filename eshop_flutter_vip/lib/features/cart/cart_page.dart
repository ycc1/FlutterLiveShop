import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_providers.dart';
import 'package:go_router/go_router.dart';

class CartPage extends ConsumerWidget {
  const CartPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartStateProvider);
    final total = ref.read(cartStateProvider.notifier).total;
    return Scaffold(
      appBar: AppBar(title: const Text('購物車')),
      body: items.isEmpty
          ? const Center(child: Text('購物車是空的'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) => ListTile(
                leading: CircleAvatar(
                    backgroundImage: NetworkImage(items[i].product.imageUrl)),
                title: Text(items[i].product.title),
                subtitle: Text('x${items[i].qty}'),
                trailing: Text('\$${items[i].subtotal.toStringAsFixed(2)}'),
                onLongPress: () => ref
                    .read(cartStateProvider.notifier)
                    .remove(items[i].product.id),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
                child: Text('合計：\$${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge)),
            FilledButton(
                onPressed: () => context.push('/checkout'),
                child: const Text('結帳')),
          ]),
        ),
      ),
    );
  }
}
