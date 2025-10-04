import 'product.dart';
class CartItem {
  final Product product;
  final int qty;
  const CartItem(this.product, this.qty);
  CartItem copyWith({int? qty}) => CartItem(product, qty ?? this.qty);
  double get subtotal => product.price * qty;
}