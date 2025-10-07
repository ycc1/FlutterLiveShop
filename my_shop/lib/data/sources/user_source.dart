import '../models/user_profile.dart';

abstract class UserSource {
  Future<UserProfile> me();
  Future<UserProfile> updatePoints(int delta);
  Future<UserProfile> addBalance(double delta);
  Future<UserProfile> deductBalance(double delta);
}

class DummyUserSource implements UserSource {
  UserProfile _me = UserProfile.mock();

  @override
  Future<UserProfile> me() async => _me;

  @override
  Future<UserProfile> updatePoints(int delta) async {
    final total = (_me.points + delta).clamp(0, 1 << 30);
    final vip = _tier(total);
    _me = _me.copyWith(points: total, vipLevel: vip);
    return _me;
  }

  @override
  Future<UserProfile> addBalance(double delta) async {
    final newBalance = (_me.balance + delta).clamp(0, 1e12);
    _me = _me.copyWith(balance: newBalance.toDouble());
    return _me;
  }

  @override
  Future<UserProfile> deductBalance(double delta) async {
    final newBalance = (_me.balance - delta);
    if (newBalance < -1e-6) {
      throw Exception('余额不足');
    }
    _me = _me.copyWith(balance: newBalance);
    return _me;
  }

  String _tier(int pts) {
    if (pts >= 5000) return 'Platinum';
    if (pts >= 2000) return 'Gold';
    if (pts >= 500) return 'Silver';
    return 'Bronze';
  }
}
