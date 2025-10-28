//订单数据结构
class OrderCreateResponse {
  final int orderId;
  final String qrCodeUrl;

  OrderCreateResponse({
    required this.orderId,
    required this.qrCodeUrl,
  });

  factory OrderCreateResponse.fromJson(Map<String, dynamic> json) {
    return OrderCreateResponse(
      orderId: json['orderId'],
      qrCodeUrl: json['qrCodeUrl'],
    );
  }
}

class OrderModel {
  final int id;
  final double totalAmount;
  final String status;
  final String qrCodeUrl;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.qrCodeUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'],
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        status: json['status'] ?? 'Pending',
        qrCodeUrl: json['qrCodeUrl'] ?? '',
      );
}
