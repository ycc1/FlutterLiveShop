class AuthResult { final String token; final String userId; AuthResult(this.token, this.userId); }
abstract class AuthService {
  Future<AuthResult> signIn({required String email, required String password});
  Future<void> signOut();
  Future<bool> validate(String token);
}
class MockAuthService implements AuthService {
  String? _token;
  @override
  Future<AuthResult> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if(email.isEmpty || password.isEmpty) { throw Exception('Email/Password 不可空'); }
    _token = 'mock.jwt.${DateTime.now().millisecondsSinceEpoch}';
    return AuthResult(_token!, 'u1');
  }
  @override Future<void> signOut() async { _token = null; }
  @override Future<bool> validate(String token) async => token == _token && token.isNotEmpty;
}
