class Address { 
  final String name, phone, line1, city;
  const Address({required this.name, required this.phone, required this.line1, required this.city});
}
class OrderItem {
  final String productId; final String title; final double price; final int qty;
  const OrderItem({required this.productId, required this.title, required this.price, required this.qty});
  double get subtotal => price*qty;
}
class Order {
  final String id; final List<OrderItem> items; final Address address; final double total; final String status;
  const Order({required this.id, required this.items, required this.address, required this.total, this.status='pending'});
}
