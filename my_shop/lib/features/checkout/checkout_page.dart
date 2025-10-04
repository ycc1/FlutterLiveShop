// lib/features/checkout/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_providers.dart';
import '../../services/payment_service.dart';

final paymentServiceProvider = Provider<PaymentService>((_) => MockPaymentService());

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartStateProvider);
    final total = ref.read(cartStateProvider.notifier).total;
    return Scaffold(
      appBar: AppBar(title: const Text('結帳')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('商品 (${items.length})', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Expanded(child: ListView.builder(itemCount: items.length, itemBuilder: (_, i){
            final it = items[i];
            return ListTile(title: Text(it.product.title), subtitle: Text('x${it.qty}'), trailing: Text('\$${it.subtotal.toStringAsFixed(2)}'));
          })),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
            const Text('合計'), Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge)
          ]),
          const SizedBox(height: 12),
          FilledButton(onPressed: () async {
            final svc = ref.read(paymentServiceProvider);
            final intent = await svc.createIntent((total*100).round());
            final ok = await svc.confirm(intent.id);
            if(ok){
              if(context.mounted){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('付款成功')));
              }
              await ref.read(cartStateProvider.notifier).clear();
            }
          }, child: const Text('付款')),
        ]),
      ),
    );
  }
}