import '../models/user_profile.dart';
import '../sources/user_source.dart';

class UserRepository {
  final UserSource source;
  UserRepository(this.source);
  Future<UserProfile> me() => source.me();
  Future<UserProfile> addPoints(int delta) => source.updatePoints(delta);
  Future<UserProfile> addBalance(double delta) => source.addBalance(delta);
  Future<UserProfile> deductBalance(double delta) =>
      source.deductBalance(delta);
}
