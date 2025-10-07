import '../models/user_profile.dart';
abstract class UserSource { Future<UserProfile> me(); Future<UserProfile> updatePoints(int delta); }

class DummyUserSource implements UserSource {
  UserProfile _me = const UserProfile(
    id:'u1', name:'Alice', email:'alice@example.com', avatar:'https://i.pravatar.cc/150?img=32',
    points: 0, vipLevel: 'Bronze',
  );
  @override Future<UserProfile> me() async => _me;
  @override Future<UserProfile> updatePoints(int delta) async {
    final total = (_me.points + delta).clamp(0, 1<<31);
    final vip = _tier(total);
    _me = UserProfile(id:_me.id, name:_me.name, email:_me.email, avatar:_me.avatar, points: total, vipLevel: vip);
    return _me;
  }
  String _tier(int pts){
    if(pts >= 5000) return 'Platinum';
    if(pts >= 2000) return 'Gold';
    if(pts >= 500)  return 'Silver';
    return 'Bronze';
  }
}
