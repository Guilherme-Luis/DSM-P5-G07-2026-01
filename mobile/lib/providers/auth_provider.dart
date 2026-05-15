import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../core/token_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  final TokenStorage tokenStorage;

  bool isLoading = false;
  bool isLoggedIn = false;
  String? token;
  String? userRole; 
  String? userId;
  String? userName;

  AuthProvider({required this.authService, required this.tokenStorage});

  Future<void> init() async {
    token = await tokenStorage.getToken();
    if (token != null && !JwtDecoder.isExpired(token!)) {
      _processToken(token!);
    } else {
      await logout();
    }
  }

  void _processToken(String tokenValue) {
    token = tokenValue;
    isLoggedIn = true;
    
    Map<String, dynamic> decodedToken = JwtDecoder.decode(tokenValue);
    userId = decodedToken['userId']?.toString();
    userRole = decodedToken['role']?.toString().toUpperCase();
    userName = decodedToken['name']?.toString();
    
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final newToken = await authService.login(email, password);
      await tokenStorage.saveToken(newToken);
      _processToken(newToken);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await authService.logout();
    } catch (_) {}
    await tokenStorage.clearToken();
    token = null;
    isLoggedIn = false;
    userRole = null;
    userId = null;
    userName = null;
    notifyListeners();
  }
}
