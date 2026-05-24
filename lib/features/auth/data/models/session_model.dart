class SessionModel {
  final String userId;
  final String accessToken;

  final bool isLoggedIn;

  final DateTime loginAt;
  final DateTime expiresAt;

  SessionModel({
    required this.userId,
    required this.accessToken,
    required this.isLoggedIn,
    required this.loginAt,
    required this.expiresAt,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      userId: map['userId'],
      accessToken: map['accessToken'],
      isLoggedIn: map['isLoggedIn'],
      loginAt: DateTime.parse(map['loginAt']),
      expiresAt: DateTime.parse(map['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'accessToken': accessToken,
      'isLoggedIn': isLoggedIn,
      'loginAt': loginAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}