class UserProfile {
  final String id;

  /// 用户ID
  final String userName;

  /// 用户名
  final String? nickName;

  /// 昵称
  final String email;

  /// 邮箱
  final String mobile;

  /// 手机号
  final int sex;

  /// 性别[1男2女3未知]
  final DateTime birthday;

  /// 生日
  final String avatarImage;

  /// 头像
  final String parentUserName;

  /// 推荐人
  final int points;

  /// 累计积分（用于 VIP 升级）
  final String vipLevel;

  /// VIP 等级：Bronze / Silver / Gold / Platinum
  final double balance;

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
    this.vipLevel = 'Bronze',
    this.balance = 0.0,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? nickName,
    String? email,
    String? mobile,
    int? sex,
    String? avatarImage,
    String? parentUserName,
    int? points,
    String? vipLevel,
    double? balance,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userName: name ?? userName,
      nickName: nickName ?? this.nickName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      sex: sex ?? this.sex,
      birthday: birthday,
      avatarImage: avatarImage ?? this.avatarImage,
      parentUserName: parentUserName ?? this.parentUserName,
      points: points ?? this.points,
      vipLevel: vipLevel ?? this.vipLevel,
      balance: balance ?? this.balance,
    );
  }

  factory UserProfile.mock() => UserProfile(
        id: 'u001',
        userName: 'testuser',
        nickName: '测试用户',
        email: 'user@example.com',
        mobile: '0912345678',
        sex: 1,
        birthday: DateTime(1990, 1, 1),
        avatarImage: '',
        parentUserName: '',
        points: 0,
        vipLevel: 'Bronze',
        balance: 0.0,
      );
}
