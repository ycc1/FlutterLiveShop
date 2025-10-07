import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/payment_service.dart';
import '../../providers/user_providers.dart';

// 充值选项（你的结构）
const rechargeOptions = [
  {
    'name': '电子钱包',
    'channels': [
      {'text': 'Gcash', 'amounts': [100, 200, 300, 500, 1000, 5000]},
      {'text': 'PayMaya', 'amounts': [100, 200, 300, 500, 1000, 5000]},
    ]
  },
  {
    'name': '银行转帐',
    'channels': [
      {'text': 'BDO', 'amounts': [100, 200, 300, 500, 1000, 5000]},
      {'text': 'BPI', 'amounts': [100, 200, 300, 500, 1000, 5000]},
    ]
  },
  {
    'name': '线上刷卡',
    'channels': [
      {'text': 'Paypal', 'amounts': [100, 200, 300, 500, 1000, 5000]},
    ]
  },
];

final paymentServiceProvider = Provider<PaymentService>((_) => MockPaymentService());

class RechargePage extends ConsumerStatefulWidget {
  const RechargePage({super.key});
  @override
  ConsumerState<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends ConsumerState<RechargePage> {
  int methodIndex = 0;    // 电子钱包 / 银行 / 刷卡
  int channelIndex = 0;   // Gcash / BPI / Paypal
  int? selectedAmount;

  @override
  Widget build(BuildContext context) {
    final method = rechargeOptions[methodIndex];
    final channels = (method['channels'] as List);
    final channel = channels[channelIndex] as Map;
    final amounts = (channel['amounts'] as List).cast<int>();

    final me = ref.watch(meProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('充值')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (me.hasValue)
              Card(
                child: ListTile(
                  title: Text('当前余额：${me.value!.balance.toStringAsFixed(2)}'),
                  subtitle: Text('积分：${me.value!.points}   VIP：${me.value!.vipLevel}'),
                ),
              ),
            const SizedBox(height: 8),
            Text('支付方式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: List.generate(rechargeOptions.length, (i) {
                final name = rechargeOptions[i]['name'] as String;
                final selected = methodIndex == i;
                return ChoiceChip(
                  label: Text(name),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      methodIndex = i;
                      channelIndex = 0;
                      selectedAmount = null;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),

            Text('渠道', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: List.generate(channels.length, (i) {
                final text = (channels[i] as Map)['text'] as String;
                final selected = channelIndex == i;
                return ChoiceChip(
                  label: Text(text),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      channelIndex = i;
                      selectedAmount = null;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),

            Text('选择金额', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                itemCount: amounts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.8),
                itemBuilder: (_, i) {
                  final a = amounts[i];
                  final selected = selectedAmount == a;
                  return InkWell(
                    onTap: () => setState(() => selectedAmount = a),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? Theme.of(context).colorScheme.primary.withOpacity(.12) : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor),
                      ),
                      child: Text(a.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: selected ? Theme.of(context).colorScheme.primary : null,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.payment),
                label: Text(selectedAmount == null ? '请选择金额' : '立即支付 ${selectedAmount!}'),
                onPressed: selectedAmount == null ? null : () async {
                  final amount = selectedAmount!;
                  // 1) 假金流走一遍
                  final svc = ref.read(paymentServiceProvider);
                  final intent = await svc.createIntent(amount * 100); // 分
                  final ok = await svc.confirm(intent.id);
                  if (!ok || !mounted) return;

                  // 2) 充值 -> 加余额
                  await ref.read(meProvider.notifier).addBalance(amount.toDouble());

                  // 3) 送积分（例：1 元 = 10 积分）
                  final points = amount * 10;
                  await ref.read(meProvider.notifier).addPoints(points);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('充值成功（${method['name']} - ${channel['text']}：$amount），余额 +$amount，积分 +$points')),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
