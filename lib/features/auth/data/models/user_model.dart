class UserModel {
  final String id;

  final String username;
  final String email;
  final String fullName;
  final String? photoUrl;

  final int level;
  final double xp;
  final int streak;
  final DateTime? lastStreakDate;
  final List<String> streakHistory;

  final int dailyTargetMinutes;

  final bool isEmailVerified;

  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.photoUrl,
    this.level = 1,
    this.xp = 0.0,
    this.streak = 0,
    this.lastStreakDate,
    this.streakHistory = const [],
    this.dailyTargetMinutes = 120,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      photoUrl: map['photoUrl'],
      level: map['level'] ?? 1,
      xp: (map['xp'] ?? 0.0).toDouble(),
      streak: map['streak'] ?? 0,
      lastStreakDate: map['lastStreakDate'] != null
          ? DateTime.parse(map['lastStreakDate'])
          : null,
      streakHistory: map['streakHistory'] != null 
          ? List<String>.from(map['streakHistory']) 
          : [],
      dailyTargetMinutes: map['dailyTargetMinutes'] ?? 120,
      isEmailVerified: map['isEmailVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'level': level,
      'xp': xp,
      'streak': streak,
      'lastStreakDate': lastStreakDate?.toIso8601String(),
      'streakHistory': streakHistory,
      'dailyTargetMinutes': dailyTargetMinutes,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
