import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;

  final AuthService _authService = AuthService();

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    final result = await _authService.login(email: email, password: password);
    _setLoading(false);

    if (result['success']) {
      _user = result['user'];
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    _errorMessage = result['message'];
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );
    _setLoading(false);

    if (result['success']) {
      _user = result['user'];
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    _errorMessage = result['message'];
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
