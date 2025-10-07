import '../../core/backend.dart';
import '../models/user_profile.dart';
import 'user_source.dart';

/// HTTP implementation of [UserSource].
/// It uses [ApiClient] and expects the backend to expose simple JSON endpoints.
class HttpUserSource implements UserSource {
  final ApiClient client;

  HttpUserSource({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<UserProfile> me() async {
    final json = await client.getJson('/user/me');
    return _fromJson(json);
  }

  @override
  Future<UserProfile> updatePoints(int delta) async {
    final json = await client.postJson('/user/points', body: {'delta': delta});
    return _fromJson(json);
  }

  @override
  Future<UserProfile> addBalance(double delta) async {
    final json =
        await client.postJson('/user/balance/add', body: {'delta': delta});
    return _fromJson(json);
  }

  @override
  Future<UserProfile> deductBalance(double delta) async {
    final json =
        await client.postJson('/user/balance/deduct', body: {'delta': delta});
    return _fromJson(json);
  }

  UserProfile _fromJson(Map<String, dynamic> json) {
    // Map backend fields to model. Make conservative assumptions and fallbacks.
    return UserProfile(
      id: json['id']?.toString() ?? '',
      userName:
          json['userName']?.toString() ?? json['username']?.toString() ?? '',
      nickName: json['nickName']?.toString() ?? json['nick_name']?.toString(),
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      sex: (json['sex'] is int)
          ? json['sex'] as int
          : int.tryParse(json['sex']?.toString() ?? '') ?? 3,
      birthday: DateTime.tryParse(json['birthday']?.toString() ?? '') ??
          DateTime(1970, 1, 1),
      avatarImage:
          json['avatarImage']?.toString() ?? json['avatar']?.toString() ?? '',
      parentUserName: json['parentUserName']?.toString() ??
          json['referrer']?.toString() ??
          '',
      points: (json['points'] is int)
          ? json['points'] as int
          : int.tryParse(json['points']?.toString() ?? '') ?? 0,
      vipLevel: json['vipLevel']?.toString() ?? 'Bronze',
      balance: (json['balance'] is num)
          ? (json['balance'] as num).toDouble()
          : double.tryParse(json['balance']?.toString() ?? '') ?? 0.0,
    );
  }
}
