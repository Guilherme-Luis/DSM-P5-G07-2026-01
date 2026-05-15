import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';

class UsersProvider extends ChangeNotifier {
  final UserService userService;

  List<AppUser> _users = [];
  bool _isLoading = false;
  String? _error;

  UsersProvider({required this.userService});

  List<AppUser> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await userService.listAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRole(String userId, String newRole) async {
    try {
      await userService.updateUserRole(userId, newRole);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = AppUser(
          id: _users[index].id,
          name: _users[index].name,
          email: _users[index].email,
          role: newRole.toUpperCase(),
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await userService.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
