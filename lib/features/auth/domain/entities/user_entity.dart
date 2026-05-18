class UserEntity {
  final int? id;
  final String username;
  final String email;
  final String password;

  UserEntity({
    this.id,
    required this.username,
    required this.email,
    required this.password,
  });
}