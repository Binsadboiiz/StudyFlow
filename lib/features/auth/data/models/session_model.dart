import 'package:isar/isar.dart';
part 'session_model.g.dart';

@collection
class SessionModel {
  Id id = 0;
  late int userId;
  late bool isLoggedIn;
}