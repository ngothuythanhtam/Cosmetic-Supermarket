import 'package:flutter/foundation.dart';
import '../../../models/user.dart';
import '../../../services/users_service.dart';
class AdminUserManager with ChangeNotifier {
  final UsersService _userService = UsersService();
  List<User> _users = [];

  List<User> get customers => [..._users];

  Future<void> adminFetchUsers({String? category}) async {
    _users = await _userService.adminFetchUsers();
    notifyListeners();
  }
}
