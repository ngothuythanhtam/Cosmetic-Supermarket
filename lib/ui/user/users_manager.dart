import 'package:flutter/foundation.dart';
import '../../../models/user.dart';
import '../../../services/users_service.dart';
import 'dart:io';

class UsersManager with ChangeNotifier {
  final UsersService _usersService = UsersService();
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> fetchUser() async {
    try {
      final userData = await _usersService.fetchUser();
      if (userData != null) {
        _currentUser = userData;
        print('Fetched user with email: ${_currentUser?.email}');
        notifyListeners();
      } else {
        throw Exception('User data not found');
      }
    } catch (error) {
      print('Error fetching user: $error');
      throw error;
    }
  }

  Future<void> updateUser(User updatedUser, {File? avatarFile}) async {
    try {
      if (_currentUser == null) {
        throw Exception('No user data available to update');
      }
      final updatedUserData =
          await _usersService.updateUser(updatedUser, avatarFile: avatarFile);
      if (updatedUserData != null) {
        _currentUser = updatedUserData;
        notifyListeners();
      } else {
        throw Exception('Failed to update user');
      }
    } catch (error) {
      print('Error updating user: $error');
      throw error;
    }
  }

  Future<void> addUser(User newUser, {File? avatarFile}) async {
    try {
      final addedUser =
          await _usersService.addUser(newUser, avatarFile: avatarFile);
      if (addedUser != null) {
        _currentUser = addedUser;
        notifyListeners();
      } else {
        throw Exception('Failed to add user');
      }
    } catch (error) {
      print('Error adding user: $error');
      throw error;
    }
  }

  Future<void> deleteUser() async {
    try {
      if (_currentUser == null) {
        throw Exception('No user data available to delete');
      }
      print('Starting user deletion...');
      final success = await _usersService.deleteUser();
      if (success) {
        _currentUser = null;
        print('User deletion completed, notifying listeners...');
        notifyListeners();
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (error) {
      print('Error deleting user in manager: $error');
      throw error;
    }
  }
}
