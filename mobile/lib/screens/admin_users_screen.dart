import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../providers/users_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().loadUsers();
    });
  }

  Future<void> _changeRole(AppUser user, String newRole) async {
    try {
      await context.read<UsersProvider>().updateRole(user.id, newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cargo de ${user.name} alterado para $newRole')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao alterar cargo: $e')),
        );
      }
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Usuário?'),
        content: Text('Deseja realmente excluir ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<UsersProvider>().deleteUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário removido')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = context.read<AuthProvider>().userId;

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Usuários')),
      body: Consumer<UsersProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.users.isEmpty) {
            return const _UsersShimmer();
          }

          if (provider.error != null && provider.users.isEmpty) {
            return Center(child: Text('Erro: ${provider.error}'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadUsers(),
            child: provider.users.isEmpty
                ? const Center(child: Text('Nenhum usuário encontrado.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      final bool isAdmin = user.role == 'ADMIN';
                      final isMe = user.id == currentUserId;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isAdmin ? Colors.amber[100] : theme.colorScheme.primaryContainer,
                            child: Icon(
                              isAdmin ? Icons.admin_panel_settings : Icons.person,
                              color: isAdmin ? Colors.amber[900] : theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(user.email),
                          trailing: isMe 
                            ? const Chip(label: Text('VOCÊ'), visualDensity: VisualDensity.compact)
                            : PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'role') {
                                    _changeRole(user, isAdmin ? 'USER' : 'ADMIN');
                                  } else if (value == 'delete') {
                                    _deleteUser(user);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'role',
                                    child: Text(isAdmin ? 'Remover Admin' : 'Tornar Admin'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Excluir Usuário', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _UsersShimmer extends StatelessWidget {
  const _UsersShimmer();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 10,
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: SizedBox(height: 70, width: double.infinity),
        ),
      ),
    );
  }
}
