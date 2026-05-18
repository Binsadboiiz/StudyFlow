import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String username;
  
  @Index(unique: true, replace: true)
  late String email;
  
  late String password;
}