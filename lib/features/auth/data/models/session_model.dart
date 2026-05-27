/// Represents an authentication session for a user.
/// Contains details such as token, login status, and expiration time.
class SessionModel {
  /// The unique identifier of the user associated with this session.
  final String userId;

  /// The access token used for authenticated requests.
  final String accessToken;

  /// Indicates whether the user is currently logged in.
  final bool isLoggedIn;

  /// The timestamp when the user logged in.
  final DateTime loginAt;

  /// The timestamp when this session expires.
  final DateTime expiresAt;

  /// Creates a [SessionModel] instance.
  SessionModel({
    required this.userId,
    required this.accessToken,
    required this.isLoggedIn,
    required this.loginAt,
    required this.expiresAt,
  });

  /// Creates a [SessionModel] from a map of data, typically retrieved from local storage or an API.
  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      userId: map['userId'],
      accessToken: map['accessToken'],
      isLoggedIn: map['isLoggedIn'],
      loginAt: DateTime.parse(map['loginAt']),
      expiresAt: DateTime.parse(map['expiresAt']),
    );
  }

  /// Converts the [SessionModel] into a map structure for storage or transmission.
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