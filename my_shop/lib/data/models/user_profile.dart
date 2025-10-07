class UserProfile {
  final String id;
  final String name;
  final String email;

  /// 累计积分（用于 VIP 升级）
  final int points;

  /// VIP 等级：Bronze / Silver / Gold / Platinum
  final String vipLevel;

  /// 钱包余额（货币单位自己定义：₱/NT$/USD）
  final double balance;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.points = 0,
    this.vipLevel = 'Bronze',
    this.balance = 0.0,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    int? points,
    String? vipLevel,
    double? balance,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      points: points ?? this.points,
      vipLevel: vipLevel ?? this.vipLevel,
      balance: balance ?? this.balance,
    );
  }

  factory UserProfile.mock() => const UserProfile(
        id: 'u001',
        name: '测试用户',
        email: 'user@example.com',
        points: 0,
        vipLevel: 'Bronze',
        balance: 0.0,
      );
}
