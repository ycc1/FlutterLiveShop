// 订单 API 服务import 'dart:convert';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../data/network/api_client.dart';
import 'order_model.dart';

class OrderService {
  final String baseUrl;

  const OrderService({
    this.baseUrl = AppConfig.apiBaseUrl,
  });

  // 建立訂單
  Future<OrderCreateResponse?> createOrder({
    required String userId,
    required double total,
    required String token,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse('$baseUrl/api/Order/CreateOrderv1');
    final body = {
      'userId': userId,
      'totalAmount': total,
      'paymentMethod': 'GCash', // or Maya, Wallet...
      'items': items,
    };

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Host': AppConfig.apiBaseUrl,
        'Access-Control-Allow-Origin': '*',
        'Content-Length': '4000', // 初始值，后续会覆盖
        'X-Platform': 'flutter', // ← 可自定义平台标识
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return OrderCreateResponse.fromJson(data);
    } else {
      print('❌ CreateOrder failed: ${res.statusCode} ${res.body}');
      return null;
    }
  }

  // 取得使用者所有訂單
  Future<List<OrderModel>> getOrders(String userId) async {
    final url = Uri.parse('$baseUrl/api/Order/GetOrderList?userId=$userId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }
    return [];
  }

  // 重新取得付款 QRCode
  Future<String?> getPaymentQr(int orderId) async {
    final url = Uri.parse('$baseUrl/api/Order/GetPaymentQRCode/$orderId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['qrCodeUrl'];
    }
    return null;
  }
}
