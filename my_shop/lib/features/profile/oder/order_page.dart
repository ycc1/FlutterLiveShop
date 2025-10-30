// lib/features/checkout/order_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/network/api_client.dart';
import '../../../providers/api_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/user_providers.dart';
import '../../checkout/order_model.dart';         // 复用你的模型（可见下方简版）
import 'package:go_router/go_router.dart';

import '../../checkout/order_service.dart';

/// —— Provider：订单列表（带分页） —— ///
final orderListProvider = StateNotifierProvider.autoDispose<
    OrderListNotifier, AsyncValue<List<OrderModel>>>((ref) {
      final api = ApiClient (ref: ref);
      final svc = OrderService(api);
    return OrderListNotifier(svc);
  }
);

class OrderListNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  OrderListNotifier(this.svc) : super(const AsyncValue.loading()) {
    refresh();
  }

  final OrderService svc;
  int _page = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    print('refresh: 进入查询');

    try {
      final list = await _fetch(page: _page);

      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final prev = state.value ?? const <OrderModel>[];
    print('loadMore: 进入查询');

    try {
      final nextPage = _page + 1;
      final list = await _fetch(page: nextPage);
      _page = nextPage;
      _hasMore = list.length >= _pageSize;
      state = AsyncValue.data([...prev, ...list]);
    } catch (e, st) {
      // 保留已有数据并报告错误
      state = AsyncValue.data(prev);
      debugPrint('LoadMore error: $e');
    }
  }

  Future<List<OrderModel>> _fetch({required int page}) async {
    final res = await svc.getOrders(page);
    if (res == null) {
      throw Exception('response is null');
    }

    // final data = res;
    // final items = data.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    _hasMore = res.length >= _pageSize;
    return res;
  }
}

/// —— UI：订单记录页 —— ///
class OrderPage extends ConsumerWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider).valueOrNull;
    final listAsync = ref.watch(orderListProvider);
    final notifier = ref.read(orderListProvider.notifier);
    
    final auth = ref.read(authProvider);
    final token = auth.token;
    
    Future<void> refresh() async {
      return notifier.refresh();
    }
    
    Future<void> loadMore() async {
      return notifier.loadMore();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('订单记录')),
      body: RefreshIndicator(
        onRefresh: () => refresh(),
        child: listAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Icon(Icons.warning_amber_rounded, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              Center(child: Text('加载失败：$err')),
              const SizedBox(height: 12),
              Center(child: OutlinedButton(onPressed: () => refresh(), child: const Text('重试'))),
            ],
          ),
          data: (orders) {
            if (orders.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  const Icon(Icons.receipt_long_outlined, size: 60),
                  const SizedBox(height: 12),
                  const Center(child: Text('暂无订单')),
                  Center(child: OutlinedButton(onPressed: () => refresh(), child: const Text('重试'))),
                  const SizedBox(height: 8),
                  Center(child: Text('去逛逛，挑点喜欢的～', style: TextStyle(color: Colors.black54))),
                ],
              );
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200 &&
                    notifier.hasMore) {
                  loadMore();
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length + 1,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  if (i == orders.length) {
                    // 底部加载更多指示
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: notifier.hasMore
                            ? const SizedBox(
                                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('— 没有更多了 —'),
                      ),
                    );
                  }
                  final it = orders[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        it.imageUrl ?? '',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        headers: {'Access-Control-Allow-Origin': '*', },
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                    title: Text(
                      it.name ?? '商品',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('订单号：${it.orderId}'),
                        Text('金额：\$${(it.amount ?? 0).toStringAsFixed(2)}    数量：${it.nums ?? 1}'),
                        Text('时间：${it.createTime ?? '-'}'),
                      ],
                    ),
                    trailing: _StatusAndAction(it: it),
                    onTap: () {
                      // 进入详情（可自定义详情页）
                      context.push('/orderDetail', extra: it);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusAndAction extends ConsumerWidget {
  const _StatusAndAction({required this.it});
  final OrderModel it;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 简易状态映射：根据后端真实字段自行调整
    final status = it.status ?? 'UNPAID';
    final color = {
      'PAID': Colors.green,
      'UNPAID': Colors.orange,
      'CLOSED': Colors.grey,
      'REFUND': Colors.redAccent,
    }[status] ?? Colors.orange;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        if (status == 'UNPAID')
          OutlinedButton(
            onPressed: () {
              // 去付款（如果你已有 /orderQR 页面）
              context.push('/orderQR', extra: OrderCreateResponse(orderId: it.orderId ?? '', qrCodeUrl: '', name: it.name, amount: it.amount, imageUrl: it.imageUrl));
            },
            child: const Text('去付款'),
          ),
      ],
    );
  }
}
