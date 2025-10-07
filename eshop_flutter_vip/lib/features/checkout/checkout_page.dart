import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_providers.dart';
import '../../services/payment_service.dart';
import '../../providers/user_providers.dart';

final paymentServiceProvider = Provider<PaymentService>((_)=> MockPaymentService());

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({Key? key}) : super(key: key);
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('合計'),
            Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final svc = ref.read(paymentServiceProvider);
                final intent = await svc.createIntent((total*100).round());
                final ok = await svc.confirm(intent.id);
                if(ok && context.mounted){
                  // ✅ 消費累積積分：1 美元 = 10 點（示例）
                  final points = (total * 10).round();
                  await ref.read(meProvider.notifier).addPoints(points);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('付款成功，獲得 $points 積分')));
                  await ref.read(cartStateProvider.notifier).clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('付款'),
            ),
          ),
        ]),
      ),
    );
  }
}
