import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((_) => MockAuthService());

class AuthState {
  final String? token;
  final String? userId;
  final bool loading;
  final Object? error;
  const AuthState({this.token, this.userId, this.loading = false, this.error});
  bool get isSignedIn => token != null;
  AuthState copyWith(
          {String? token, String? userId, bool? loading, Object? error}) =>
      AuthState(
          token: token ?? this.token,
          userId: userId ?? this.userId,
          loading: loading ?? this.loading,
          error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService svc;
  AuthNotifier(this.svc) : super(const AuthState());
  Future<void> signIn(String email, String pwd) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final r = await svc.signIn(email: email, password: pwd);
      state = AuthState(token: r.token, userId: r.userId);
    } catch (e) {
      state = AuthState(error: e, loading: false);
    }
  }

  Future<void> signOut() async {
    await svc.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
    (ref) => AuthNotifier(ref.read(authServiceProvider)));
