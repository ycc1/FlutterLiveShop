// 订单 API 服务import 'dart:convert';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../data/network/api_client.dart';
import 'order_model.dart';

class OrderService {
  final ApiClient api;
  OrderService(this.api);

  Future<OrderCreateResponse?> createOrder({
    required String userId,
    required double total,
    List<Map<String, dynamic>> items = const [],
  }) async {
    final res = await api.post<String>(
      '/api/Order/CreateOrderv1',
      data: {
        'userId': userId,
        'totalAmount': total,
        'paymentMethod': 'GCash',
        'items': items,
      },
    );
    final root = jsonDecode(res.data ?? '{}');
    final data = root['data'];
    final first = (data is List && data.isNotEmpty) ? data.first : null;
    return (first is Map<String, dynamic>)
        ? OrderCreateResponse.fromJson(first)
        : null;
  }

  Future<List<OrderModel>> getOrders(int page) async {
    final res = await api.post<String>(
      '/api/Order/GetOrderList',
      data: {'page': page, 'limit': 200},
    );
    final root = jsonDecode(res.data ?? '[]');
    dynamic box = root;
    if (box is Map && box['data'] is Map) box = box['data'];
    final list = (box is Map && box['list'] is List)
        ? box['list'] as List
        : (root is List ? root : []);
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String?> getPaymentQr(int orderId) async {
    final res = await api.get<String>('/api/Order/GetPaymentQRCode/$orderId');
    final root = jsonDecode(res.data ?? '{}');
    return (root is Map) ? root['qrCodeUrl'] as String? : null;
  }
}
