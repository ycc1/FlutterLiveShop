class PaymentIntent {
  final String id; final int amountCents; final String currency;
  PaymentIntent(this.id, this.amountCents, this.currency);
}
abstract class PaymentService {
  Future<PaymentIntent> createIntent(int amountCents, {String currency='USD'});
  Future<bool> confirm(String intentId);
}
class MockPaymentService implements PaymentService {
  @override Future<PaymentIntent> createIntent(int amountCents, {String currency='USD'}) async
    => PaymentIntent('pi_${DateTime.now().millisecondsSinceEpoch}', amountCents, currency);
  @override Future<bool> confirm(String intentId) async { await Future.delayed(const Duration(milliseconds:800)); return true; }
}
