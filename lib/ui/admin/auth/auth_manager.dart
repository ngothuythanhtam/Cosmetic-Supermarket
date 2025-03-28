import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';

class AuthManager with ChangeNotifier {
  final AuthService _authService;
  User? _loggedInUser;
  bool _isInitialized = false;
  bool _isSplashComplete = false; // New flag to track splash screen duration

  AuthManager() : _authService = AuthService() {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    _authService.onAuthChange = (User? user) {
      _loggedInUser = user;
      notifyListeners();
    };
  }

  User? get loggedInUser => _loggedInUser;
  bool get isAuth => _loggedInUser != null;
  bool get isStaff => _loggedInUser?.urole == 'staff';
  bool get isCustomer => _loggedInUser?.urole == 'customer';
  bool get isInitialized => _isInitialized;
  bool get isSplashComplete => _isSplashComplete;

  Future<void> initialize() async {
    print('🔴 Starting initialization');
    await Future.wait([
      tryAutoLogin(),
      Future.delayed(const Duration(seconds: 5)), 
    ]);
    _isInitialized = true;
    _isSplashComplete = true;
    notifyListeners();
    print('✅ Initialization complete: isAuth=$isAuth, isStaff=$isStaff');
  }

  Future<void> tryAutoLogin() async {
    print('🔴 Starting tryAutoLogin()');
    try {
      final user = await _authService.getUserFromStore();
      print(
          '✅ getUserFromStore completed: user = ${user != null ? 'exists' : 'null'}');
      if (user != null) {
        _loggedInUser = user;
      } else {
        _loggedInUser = null;
      }
      print('✅ tryAutoLogin completed successfully');
    } catch (error) {
      print('❌ Auto login error: $error');
      _loggedInUser = null;
    }
  }

  Future<void> signup(
      String username, String email, String phone, String password) async {
    try {
      print('🔴 AuthManager: Starting signup process');
      final user = await _authService.signup(username, email, phone, password);
      _loggedInUser = user;
      notifyListeners();
      print('✅ AuthManager: Signup completed successfully');
    } catch (error) {
      print('❌ Signup error in manager: $error');
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final user = await _authService.login(email, password);
      _loggedInUser = user;
      notifyListeners();
      print(
          '✅ Login successful: isAuth=$isAuth, isStaff=$isStaff, userRole=${_loggedInUser?.urole}');
    } catch (error) {
      print('❌ Login error in manager: $error');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _loggedInUser = null;
    notifyListeners();
  }
}
