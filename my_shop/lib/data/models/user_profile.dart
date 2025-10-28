class UserProfile {
  /// 用户ID
  final int id;

  /// 用户名
  final String userName;

  /// 昵称
  final String? nickName;

  /// 邮箱
  final String email;

  /// 手机号
  final String mobile;

  /// 性别[1男2女3未知]
  final int sex;

  /// 生日
  final DateTime birthday;

  /// 头像
  final String avatarImage;

  /// 推荐人
  final String parentUserName;

  /// 累计积分（用于 VIP 升级）
  final int points;

  /// 钱包余额
  final double balance;

  /// VIP 等级
  final String vipLevel;

  /// 用户 token
  final String token;

  /// 钱包余额（货币单位自己定义：₱/NT$/USD）

  const UserProfile({
    required this.id,
    required this.userName,
    required this.nickName,
    required this.email,
    required this.mobile,
    this.sex = 1,
    required this.birthday,
    required this.avatarImage,
    this.parentUserName = "",
    this.points = 0,
    this.balance = 0.0,
    required this.vipLevel,
    required this.token,
  });

  UserProfile copyWith({
    int? id,
    String? userName,
    String? nickName,
    String? email,
    String? mobile,
    int? sex,
    DateTime? birthday,
    String? avatarImage,
    String? parentUserName,
    int? points,
    double? balance,
    String? vipLevel,
    String? token,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      nickName: nickName ?? this.nickName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      sex: sex ?? this.sex,
      birthday: birthday ?? this.birthday,
      avatarImage: avatarImage ?? this.avatarImage,
      parentUserName: parentUserName ?? this.parentUserName,
      points: points ?? this.points,
      balance: balance ?? this.balance,
      vipLevel: vipLevel ?? this.vipLevel,
      token: token ?? this.token,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['userId'] ?? json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      nickName: json['nickName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      sex: json['sex'] ?? 0,
      birthday: json['birthday'] ?? DateTime(1990, 1, 1),
      avatarImage: json['avatarImage'] ?? '',
      parentUserName: json['parentUserName'] ?? '',
      points: json['points'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
      vipLevel: json['vipLevel'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'email': email,
        'mobile': mobile,
        'sex': sex,
        'birthday': birthday.toIso8601String(),
        'avatarImage': avatarImage,
        'parentUserName': parentUserName,
        'points': points,
        'balance': balance,
        'vipLevel': vipLevel,
        'token': token,
      };

  factory UserProfile.mock() => UserProfile(
        id: 0,
        userName: 'testuser',
        nickName: '测试用户',
        email: 'user@example.com',
        mobile: '0912345678',
        sex: 1,
        birthday: DateTime(1990, 1, 1),
        avatarImage: '',
        parentUserName: '',
        points: 0,
        balance: 0.0,
        vipLevel: 'Bronze',
        token: '',
      );
}
