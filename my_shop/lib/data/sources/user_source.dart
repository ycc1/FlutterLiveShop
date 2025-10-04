import '../models/user_profile.dart';

abstract class UserSource { Future<UserProfile> me(); }
class DummyUserSource implements UserSource {
  @override
  Future<UserProfile> me() async => const UserProfile(
    id: 'u1', name: 'Alice', email: 'alice@example.com', avatar: 'https://i.pravatar.cc/150?img=32');
}