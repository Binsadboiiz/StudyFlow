class UserEntity {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String fullName;

  UserEntity({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
  });
}