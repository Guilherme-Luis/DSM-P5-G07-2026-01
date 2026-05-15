import '../core/api_client.dart';

class AuthService {
  final ApiClient api;

  AuthService(this.api);

  Future<String> login(String email, String password) async {
    final response = await api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });

    return response['token'];
  }

  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await api.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });

    return response['token'];
  }

  Future<void> logout() async {
    await api.post('/auth/logout');
  }
}