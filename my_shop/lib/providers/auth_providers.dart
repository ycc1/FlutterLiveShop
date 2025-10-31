// lib/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/network/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../config/app_config.dart';
import 'user_providers.dart'; // 👈 同步用

class AuthState {
  final bool loading;
  final bool isSignedIn;
  final String? token;
  final String? error;

  const AuthState({
    this.loading = false,
    this.isSignedIn = false,
    this.token,
    this.error,
  });

  AuthState copyWith({
    bool? loading,
    bool? isSignedIn,
    String? token,
    String? error,
  }) =>
      AuthState(
        loading: loading ?? this.loading,
        isSignedIn: isSignedIn ?? this.isSignedIn,
        token: token ?? this.token,
        error: error,
      );
}

final _apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: AppConfig.apiBaseUrl, ref: ref); // ← 改成你的 API Host
});

final _authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(_apiClientProvider));
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.ref, this.repo) : super(const AuthState());
  final Ref ref;
  final AuthRepository repo;

  Future<void> signIn(String account, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final userInfo = await repo.signIn(
        accountOrMobile: account,
        passwordOrCode: password,
      ); // ⬅️ 这里返回的是 UserModel?（前面已改过 AuthRepository）

      if (userInfo != null) {
        // ① 同步到 meProvider
        ref.read(meProvider.notifier).setUser(userInfo);

        // ② 自身状态（token 可选）
        final hasToken = (userInfo.token).isNotEmpty;

        state = state.copyWith(
          loading: false,
          isSignedIn: true, // 有无 token 都算已登录（按你业务）
          token: hasToken ? userInfo.token : null,
          error: null,
        );
      } else {
        state = state.copyWith(
          loading: false,
          isSignedIn: false,
          error: '登录失败：服务器未返回用户信息',
        );
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        isSignedIn: false,
        error: e.toString(),
      );
    }
  }

  // 发送短信验证码
  Future<String?> sendOtp(String mobile) async {
    try {
      await repo.sendOtp(mobile: mobile);
      return null; // null 表示成功
    } catch (e) {
      return e.toString();
    }
  }

  // 发送短信验证码
  Future<String?> sendEmailOtp(String email) async {
    try {
      await repo.sendEMailOtp(email: email);
      return null; // null 表示成功
    } catch (e) {
      return e.toString();
    }
  }

  void signOut() {
    // ① 清空 meProvider
    ref.read(meProvider.notifier).logout();
    // ② 清空自身
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.read(_authRepoProvider);
  return AuthController(ref, repo); // 👈 传入 ref
});
