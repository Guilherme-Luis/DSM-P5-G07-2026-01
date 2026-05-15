import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../core/api_client.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late NotificationService _notificationService;
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService(context.read<ApiClient>());
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _notificationService.listNotifications();
      setState(() => _notifications = notifications);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
      _loadNotifications();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Notificações')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _notifications.isEmpty
          ? const Center(child: Text('Nenhuma notificação no momento.'))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return ListTile(
                  leading: Icon(
                    notification.read ? Icons.notifications_none : Icons.notifications_active,
                    color: notification.read ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(fontWeight: notification.read ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Text(notification.message),
                  onTap: () => _markAsRead(notification.id),
                );
              },
            ),
    );
  }
}
