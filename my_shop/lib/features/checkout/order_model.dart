//订单数据结构
class OrderCreateResponse {
  final String orderId;
  final String qrCodeUrl;
  final String? name;
  final double? amount;
  final String? imageUrl;

  OrderCreateResponse({
    required this.orderId,
    required this.qrCodeUrl,
    this.name,
    this.amount,
    this.imageUrl,
  });

  factory OrderCreateResponse.fromJson(Map<String, dynamic> json) {
    return OrderCreateResponse(
      orderId: json['orderId']?.toString() ?? '',
      qrCodeUrl: json['qrCodeUrl']?.toString() ?? '', // 后端未来可能加上
      name: json['name'],
      amount: (json['amount'] ?? json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'qrCodeUrl': qrCodeUrl,
        'name': name,
        'amount': amount,
        'imageUrl': imageUrl,
      };
}

class OrderModel {
  final String? orderId;
  final int? productId;
  final String? name;
  final double? price;
  final double? amount;
  final String? imageUrl;
  final int? nums;
  final String? createTime;
  final String? status; // 自行映射
  OrderModel({
    this.orderId,
    this.productId,
    this.name,
    this.price,
    this.amount,
    this.imageUrl,
    this.nums,
    this.createTime,
    this.status,
  });
  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        orderId: j['orderId']?.toString(),
        productId: j['productId'],
        name: j['name'],
        price: (j['price'] ?? 0).toDouble(),
        amount: (j['amount'] ?? j['price'] ?? 0).toDouble(),
        imageUrl: j['imageUrl'],
        nums: j['nums'] ?? 1,
        createTime: j['createTime'],
        status: _mapStatus(j),
      );
  static String _mapStatus(Map<String, dynamic> j) {
    // 如果后端有显式状态字段就用它；没有就通过 msg / payStatus / shipStatus 自己映射
    final s =
        (j['status'] ?? j['payStatus'] ?? j['orderStatus'] ?? '').toString();
    if (s.isEmpty) return 'UNPAID';
    return s.toUpperCase();
  }
}
