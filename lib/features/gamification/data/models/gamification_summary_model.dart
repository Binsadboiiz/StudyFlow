/// Model đại diện cho tóm tắt điểm, cấp độ, streak, tiến độ ngày và danh hiệu nổi bật của người dùng.
class GamificationSummaryModel {
  final int level;
  final double xpPoints;
  final double nextLevelXp;
  final int coins;
  final int streak;
  final int dailyTargetMinutes;
  final int focusedMinutesToday;
  
  // Danh hiệu nổi bật (nullable)
  final String? featuredBadgeId;
  final String? featuredBadgeName;
  final String? featuredBadgeIcon;

  GamificationSummaryModel({
    required this.level,
    required this.xpPoints,
    required this.nextLevelXp,
    required this.coins,
    required this.streak,
    required this.dailyTargetMinutes,
    required this.focusedMinutesToday,
    this.featuredBadgeId,
    this.featuredBadgeName,
    this.featuredBadgeIcon,
  });

  /// Factory chuyển đổi dữ liệu từ JSON map được trả về từ API backend.
  factory GamificationSummaryModel.fromJson(Map<String, dynamic> json) {
    return GamificationSummaryModel(
      level: json['level'] ?? 1,
      xpPoints: (json['expPoints'] ?? 0.0).toDouble(),
      nextLevelXp: (json['nextLevelXp'] ?? 100.0).toDouble(),
      coins: json['coins'] ?? 0,
      streak: json['streak'] ?? 0,
      dailyTargetMinutes: json['dailyTargetMinutes'] ?? 60,
      focusedMinutesToday: json['focusedMinutesToday'] ?? 0,
      featuredBadgeId: json['featuredBadgeId'],
      featuredBadgeName: json['featuredBadgeName'],
      featuredBadgeIcon: json['featuredBadgeIcon'],
    );
  }

  /// Chuyển đổi đối tượng thành JSON map.
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'expPoints': xpPoints,
      'nextLevelXp': nextLevelXp,
      'coins': coins,
      'streak': streak,
      'dailyTargetMinutes': dailyTargetMinutes,
      'focusedMinutesToday': focusedMinutesToday,
      'featuredBadgeId': featuredBadgeId,
      'featuredBadgeName': featuredBadgeName,
      'featuredBadgeIcon': featuredBadgeIcon,
    };
  }
}
