/// Data model representing a user in the database.
class UserModel {
  /// The unique identifier of the user.
  final String id;

  /// The chosen username.
  final String username;
  /// The user's email address.
  final String email;
  /// The user's full name.
  final String fullName;
  /// An optional URL to the user's profile photo.
  final String? photoUrl;

  /// The user's current level.
  final int level;
  /// The user's current experience points.
  final double xp;
  /// The user's current login/activity streak.
  final int streak;
  /// The date of the last successful streak update.
  final DateTime? lastStreakDate;
  /// A history of dates when the streak was updated.
  final List<String> streakHistory;

  /// The daily target duration for the user, in minutes.
  final int dailyTargetMinutes;

  /// Indicates whether the user has verified their email.
  final bool isEmailVerified;

  /// The timestamp when the account was created.
  final DateTime createdAt;
  /// The timestamp when the account was last updated.
  final DateTime updatedAt;

  /// Creates a [UserModel] instance.
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
    this.dailyTargetMinutes = 60,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [UserModel] from a map structure, usually retrieved from a database like Firestore.
  /// 
  /// [documentId] is the unique document ID representing the user.
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
      dailyTargetMinutes: map['dailyTargetMinutes'] ?? 60,
      isEmailVerified: map['isEmailVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Converts the [UserModel] instance into a map structure suitable for database storage.
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
