import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_providers.dart';
import '../../services/payment_service.dart';
import '../../providers/user_providers.dart';

final paymentServiceProvider =
    Provider<PaymentService>((_) => MockPaymentService());

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartStateProvider);
    final total = ref.read(cartStateProvider.notifier).total; // 需要支付的总金额
    final me = ref.watch(meProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('结账')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('商品 (${items.length})',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Expanded(
              child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final it = items[i];
              return ListTile(
                title: Text(it.product.title),
                subtitle: Text('x${it.qty}'),
                trailing: Text('\$${it.subtotal.toStringAsFixed(2)}'),
              );
            },
          )),
          const Divider(),
          if (me.hasValue)
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text('钱包余额：\$${me.value!.balance.toStringAsFixed(2)}'),
                subtitle:
                    Text('积分：${me.value!.points}（VIP：${me.value!.vipLevel}）'),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('合计'),
              Text('\$${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 12),

          // 支付按钮：优先扣余额；不足则外部支付（Mock）
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final user = ref.read(meProvider).valueOrNull;
                if (user == null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('请登录后再结账')));
                  return;
                }

                final balance = user.balance;
                double need = total;

                // 1) 先用余额尽可能抵扣
                if (balance > 0) {
                  final use = balance >= need ? need : balance;
                  if (use > 0) {
                    await ref.read(meProvider.notifier).deductBalance(use);
                    need -= use;
                  }
                }

                // 2) 如仍不足，走外部支付（Mock）
                if (need > 1e-6) {
                  final svc = ref.read(paymentServiceProvider);
                  final intent =
                      await svc.createIntent((need * 100).round()); // 分
                  final ok = await svc.confirm(intent.id);
                  if (!ok) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('外部支付失败')));
                    }
                    return;
                  }
                }

                // 3) 成功后：清空购物车 + 送积分（例：1 元 = 10 积分）
                final points = (total * 10).round();
                await ref.read(meProvider.notifier).addPoints(points);
                await ref.read(cartStateProvider.notifier).clear();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('支付成功，积分 +$points')));
                  Navigator.pop(context);
                }
              },
              child: const Text('立即支付'),
            ),
          ),
        ]),
      ),
    );
  }
}
