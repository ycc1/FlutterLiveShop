//结账页
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/cart_providers.dart';
import '../../services/payment_service.dart';
import '../../providers/user_providers.dart';
import '../checkout/order_service.dart';
import '../checkout/order_model.dart';
import 'package:go_router/go_router.dart';

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
                final auth = ref.read(authProvider);
                print(ref.read(meProvider).value);

                if (user == null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('请登录后再结账')));
                  return;
                }

                final items = ref.read(cartStateProvider);
                final total = ref.read(cartStateProvider.notifier).total;

                final orderItems = items
                    .map((it) => {
                          'productId': it.product.id,
                          'title': it.product.title,
                          'qty': it.qty,
                          'price': it.product.price,
                          'subtotal': it.subtotal,
                        })
                    .toList();

                // 🔹 呼叫 API 建立訂單
                final svc = OrderService();
                final res = await svc.createOrder(
                  userId: user.id.toString(),
                  total: total,
                  items: orderItems,
                  token: auth.token ?? '',
                );

                if (res == null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('建立订单失败')));
                  return;
                }

                // ✅ 跳转付款 QR 页面
                if (context.mounted) {
                  context.push('/orderQR', extra: res);
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
