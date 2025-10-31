// lib/features/settings/user_account_service.dart
import 'dart:convert';
import '../../../data/network/api_client.dart';

class UserAccountService {
  final ApiClient api;
  UserAccountService(this.api);

  Future<void> updatePassword({
    required String oldPwd,
    required String newPwd,
    required String otpCode,
  }) async {
    final data = <String, dynamic>{'pwd': newPwd};

    if (oldPwd.isNotEmpty) {
      data['oldpwd'] = oldPwd;
    }
    if (otpCode.isNotEmpty) {
      data['otpcode'] = otpCode;
    }

    // 后端要求二选一：确保至少有一个
    if (!data.containsKey('oldpwd') && !data.containsKey('otpcode')) {
      throw Exception('请填写旧密码或 OTP 任一项');
    }

    final res = await api.post<String>('/Auth/UpdatePwd', data: data);
    final root = jsonDecode(res.data ?? '{}');
    final ok = (root['status'] == true) || (root['code'] == 200);

    if (!ok) {
      throw Exception(root['msg'] ?? '修改密码失败');
    }
    // 简单兜底：非 2xx 会在 ApiClient 抛异常，这里只要不抛就当成功。
    // 若你的后端有 {status:true/false} 可在这解析并判断。
  }

  Future<void> updateEmail({required String email}) async {
    final res =
        await api.post<String>('/Auth/UpdateEmail', data: {'email': email});
    final root = jsonDecode(res.data ?? '{}');
    final ok = (root['status'] == true) || (root['code'] == 0);
    if (!ok) throw Exception(root['msg'] ?? '修改 Email 失败');
  }
}
