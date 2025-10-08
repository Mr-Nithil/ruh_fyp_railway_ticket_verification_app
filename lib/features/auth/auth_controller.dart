import 'package:flutter/material.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/auth/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isAuthorized = false;
  bool get isAuthorized => _isAuthorized;

  AuthController() {
    // Check authorization status when controller is created
    checkAuthorization();
  }

  Future<void> login(String email, String password) async {
    try {
      await _authRepository.login(email, password);
      _isAuthorized = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signup(
    String email,
    String password,
    String name,
    String nic,
    String checkerId,
  ) async {
    try {
      await _authRepository.signup(email, password, name, nic, checkerId);
      _isAuthorized = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _isAuthorized = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void checkAuthorization() {
    _isAuthorized = _authRepository.isAuthorized();
    notifyListeners();
  }
}
