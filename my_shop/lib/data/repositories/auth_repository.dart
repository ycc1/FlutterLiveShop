import 'dart:async';
import 'dart:convert';
import '../models/user_profile.dart';
import '../network/api_client.dart';

class AuthRepository {
  final ApiClient api;
  AuthRepository(this.api);

  Future<UserProfile?> signIn({
    required String accountOrMobile,
    required String passwordOrCode,
  }) async {
    final body = {
      'account': accountOrMobile,
      'password': passwordOrCode,
      'mobile': accountOrMobile,
      'code': passwordOrCode,
    };
    try {
      final res = await api.post<String>('/Auth/SmsLogin', data: body);
      final raw = res.data ?? '';
      if (raw.isEmpty) return null;

      final root = jsonDecode(raw);
      if (root is! Map) return null;

      // 取 data、拆 userInfo 与 token
      final data = (root['data'] ?? root['Data']) as Map?;
      final userInfo = (data?['userInfo'] ?? data?['UserInfo']) as Map?;
      final tokenObj = (data?['token'] ?? data?['Token']) as Map?;

      if (userInfo == null) return null;

      final headerToken = res.headers['authorization']?.first;
      final tokenStr =
          (tokenObj?['token'] ?? tokenObj?['Token'] ?? headerToken ?? '')
              .toString();

      // 合并成一个 map，便于 UserProfile.fromJson 解析
      final merged = {
        ...userInfo, // userId / userName / mobile / balance / point ...
        'token': tokenStr
      };

      final user = UserProfile.fromJson(merged.cast<String, dynamic>());
      print(
          '[AuthRepo] userProfile built: id=${user.id}, name=${user.userName}');
      return user;
    } on TimeoutException {
      print('[AuthRepo][ERROR] request timeout');
      rethrow;
    } catch (e, st) {
      print('[AuthRepo][ERROR] $e\n$st');
      rethrow;
    }
  }

  Future<void> sendOtp({required String mobile}) async {
    await api.post<String>('/SMS/Laaffic/SendOTP/send-otp',
        data: {'numbers': mobile});
  }
}
