import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../core/api_client.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _type = 'INFO';
  bool _loading = false;

  late NotificationService _service;

  @override
  void initState() {
    super.initState();
    _service = NotificationService(context.read<ApiClient>());
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _service.createNotification(
        title: _titleCtrl.text,
        message: _messageCtrl.text,
        type: _type,
      );
      if (!mounted) return;
      _titleCtrl.clear();
      _messageCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificação enviada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar Notificação')),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _messageCtrl,
                    decoration: const InputDecoration(labelText: 'Mensagem'),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem(value: 'INFO', child: Text('Informação')),
                      DropdownMenuItem(value: 'ALERT', child: Text('Alerta')),
                      DropdownMenuItem(value: 'PROMO', child: Text('Promoção')),
                      DropdownMenuItem(value: 'EMAIL', child: Text('E-mail')),
                    ],
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _send,
                      icon: const Icon(Icons.send),
                      label: const Text('Enviar para todos'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
