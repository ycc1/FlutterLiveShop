class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final int points;        // 累计积分
  final String vipLevel;   // Bronze / Silver / Gold / Platinum
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    this.points = 0,
    this.vipLevel = 'Bronze',
  });
}
