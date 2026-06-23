import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../core/token_storage.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  final TokenStorage tokenStorage;
  UserService? userService;

  bool isLoading = false;
  bool isLoggedIn = false;
  String? token;
  String? userRole; 
  String? userId;
  String? userName;

  AuthProvider({required this.authService, required this.tokenStorage});

  void updateService(UserService service) {
    bool serviceWasNull = userService == null;
    userService = service;
    if (serviceWasNull && isLoggedIn && userId != null) {
      refreshUserData();
    }
  }

  Future<void> init() async {
    token = await tokenStorage.getToken();
    if (token != null && !JwtDecoder.isExpired(token!)) {
      await _decodeAndNotify(token!);
    } else {
      await logout();
    }
  }

  Future<void> _decodeAndNotify(String tokenValue) async {
    token = tokenValue;
    isLoggedIn = true;
    
    Map<String, dynamic> decodedToken = JwtDecoder.decode(tokenValue);
    userId = decodedToken['userId']?.toString();
    userRole = decodedToken['role']?.toString().toUpperCase();
    userName = decodedToken['name']?.toString();
    
    notifyListeners();
    await refreshUserData();
  }

  Future<void> refreshUserData() async {
    if (userId == null || userService == null) return;
    try {
      final user = await userService!.getUserById(userId!);
      userName = user.name;
      userRole = user.role?.toUpperCase();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao sincronizar dados: $e');
    }
  }

  void updateUserData({String? name}) {
    if (name != null) {
      userName = name;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final newToken = await authService.login(email, password);
      await tokenStorage.saveToken(newToken);
      await _decodeAndNotify(newToken);
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
