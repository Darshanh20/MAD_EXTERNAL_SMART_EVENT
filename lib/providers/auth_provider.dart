import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  UserRole? get userRole => _currentUser?.role;

  AuthProvider() {
    _currentUser = AuthService.instance.getCurrentUser();
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.instance.signup(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.instance.login(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.instance.logout();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
