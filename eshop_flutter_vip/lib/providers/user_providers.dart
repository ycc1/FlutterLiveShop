import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/user_repository.dart';
import '../data/sources/user_source.dart';
import '../data/models/user_profile.dart';

final userSourceProvider = Provider<UserSource>((ref)=> DummyUserSource());
final userRepoProvider = Provider<UserRepository>((ref)=> UserRepository(ref.read(userSourceProvider)));

class UserNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final UserRepository repo;
  UserNotifier(this.repo): super(const AsyncLoading()){
    _load();
  }
  Future<void> _load() async {
    try { state = AsyncData(await repo.me()); }
    catch(e, st){ state = AsyncError(e, st); }
  }
  Future<void> addPoints(int delta) async {
    try {
      final updated = await repo.addPoints(delta);
      state = AsyncData(updated);
    } catch(e, st){ state = AsyncError(e, st); }
  }
}

final meProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserProfile>>(
  (ref) => UserNotifier(ref.read(userRepoProvider)),
);
