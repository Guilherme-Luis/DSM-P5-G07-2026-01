import '../core/api_client.dart';
import '../models/app_user.dart';

class UserService {
  final ApiClient api;

  UserService(this.api);
  Future<List<AppUser>> listAllUsers() async {
    final response = await api.get('/users');
    final List data = response is List ? response : (response['users'] ?? []);
    return data.map((e) => AppUser.fromJson(e)).toList();
  }
  Future<AppUser> getUserById(String userId) async {
    final response = await api.get('/users/$userId');
    return AppUser.fromJson(response is Map && response['user'] != null ? response['user'] : response);
  }
  Future<void> updateUserData(String userId, {required String name, required String email}) async {
    await api.put('/users/$userId', body: {
      'name': name,
      'email': email,
    });
  }
  Future<void> updateUserRole(String userId, String newRole) async {
    await api.patch('/users/$userId/role', body: {
      'role': newRole.toUpperCase(),
    });
  }
  Future<void> deleteUser(String userId) async {
    await api.delete('/users/$userId');
  }
}
