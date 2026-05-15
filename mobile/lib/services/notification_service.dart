import '../core/api_client.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.read = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'INFO',
      read: json['read'] ?? false,
    );
  }
}

class NotificationService {
  final ApiClient api;

  NotificationService(this.api);

  Future<List<AppNotification>> listNotifications() async {
    final response = await api.get('/notifications');
    final List data = response is List ? response : (response['notifications'] ?? []);
    return data.map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    await api.post('/notifications', body: {
      'title': title,
      'message': message,
      'type': type,
    });
  }

  Future<void> markAsRead(String id) async {
    await api.patch('/notifications/$id');
  }

  Future<void> updateNotification(String id, Map<String, dynamic> data) async {
    await api.put('/notifications/$id', body: data);
  }

  Future<void> deleteNotification(String id) async {
    await api.delete('/notifications/$id');
  }
}
