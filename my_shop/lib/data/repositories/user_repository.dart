import '../models/user_profile.dart';
import '../sources/user_source.dart';

class UserRepository {
  final UserSource source;
  UserRepository(this.source);
  Future<UserProfile> me() => source.me();
}