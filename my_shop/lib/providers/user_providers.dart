import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/user_repository.dart';
import '../data/sources/user_source.dart';

final userSourceProvider = Provider<UserSource>((ref) => DummyUserSource());
final userRepoProvider = Provider<UserRepository>((ref) => UserRepository(ref.read(userSourceProvider)));
final meProvider = FutureProvider((ref) => ref.read(userRepoProvider).me());