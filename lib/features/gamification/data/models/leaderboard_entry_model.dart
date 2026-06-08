/// Model đại diện cho một dòng trong bảng xếp hạng.
class LeaderboardEntryModel {
  final int rank;
  final String userId;
  final String username;
  final String fullName;
  final String avatarUrl;
  final int level;
  final double expPoints;

  // Huy hiệu nổi bật
  final String? featuredBadgeId;
  final String? featuredBadgeName;
  final String? featuredBadgeIcon;

  // Thuộc tính phục vụ đa mục tiêu xếp hạng
  final int achievementsCount;
  final int petLevel;
  final String petName;

  LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    required this.level,
    required this.expPoints,
    this.featuredBadgeId,
    this.featuredBadgeName,
    this.featuredBadgeIcon,
    required this.achievementsCount,
    required this.petLevel,
    required this.petName,
  });

  /// Factory chuyển đổi từ JSON map.
  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] ?? 0,
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      level: json['level'] ?? 1,
      expPoints: (json['expPoints'] ?? 0.0).toDouble(),
      featuredBadgeId: json['featuredBadgeId'],
      featuredBadgeName: json['featuredBadgeName'],
      featuredBadgeIcon: json['featuredBadgeIcon'],
      achievementsCount: json['achievementsCount'] ?? 0,
      petLevel: json['petLevel'] ?? 0,
      petName: json['petName'] ?? '',
    );
  }

  /// Chuyển đổi thành JSON map.
  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'level': level,
      'expPoints': expPoints,
      'featuredBadgeId': featuredBadgeId,
      'featuredBadgeName': featuredBadgeName,
      'featuredBadgeIcon': featuredBadgeIcon,
      'achievementsCount': achievementsCount,
      'petLevel': petLevel,
      'petName': petName,
    };
  }
}
