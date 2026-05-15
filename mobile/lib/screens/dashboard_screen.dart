import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_products_screen.dart';
import 'admin_users_screen.dart';
import 'admin_companies_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_orders_screen.dart';
import 'user_orders_screen.dart';
import 'notification_list_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bool isAdmin = auth.userRole == 'ADMIN';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Painel Administrativo' : 'Meu Perfil'),
        elevation: 0,
        backgroundColor: isAdmin ? Colors.blueGrey[900] : theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserBanner(context, auth, isAdmin),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAdmin ? 'Gestão da Plataforma' : 'Minhas Atividades',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: isAdmin 
                      ? _buildAdminGrid(context) 
                      : _buildUserGrid(context),
                  ),
                  
                  const SizedBox(height: 32),
                  _buildLogoutSection(context, auth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBanner(BuildContext context, AuthProvider auth, bool isAdmin) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.blueGrey[900] : theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.userName ?? (isAdmin ? 'Admin' : 'Usuário'),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(isAdmin ? 'ADMINISTRADOR' : 'CLIENTE'),
                  backgroundColor: isAdmin ? Colors.amber[700] : theme.colorScheme.secondary,
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUserGrid(BuildContext context) {
    return [
      _cardItem(context, Icons.shopping_bag_outlined, 'Meus Pedidos', Colors.orange,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserOrdersScreen()))),
      _cardItem(context, Icons.notifications_none, 'Notificações', Colors.blue,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationListScreen()))),
      _cardItem(context, Icons.person_outline, 'Meus Dados', Colors.teal,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))), // Navegação adicionada
    ];
  }

  List<Widget> _buildAdminGrid(BuildContext context) {
    return [
      _cardItem(context, Icons.inventory_2_outlined, 'Produtos', Colors.indigo, 
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductsScreen()))),
      _cardItem(context, Icons.business_outlined, 'Empresas', Colors.blueGrey,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCompaniesScreen()))),
      _cardItem(context, Icons.people_outline, 'Usuários', Colors.teal,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()))),
      _cardItem(context, Icons.assignment_outlined, 'Todos Pedidos', Colors.amber[800]!,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen()))),
      _cardItem(context, Icons.campaign_outlined, 'Enviar Avisos', Colors.deepPurple,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()))),
      _cardItem(context, Icons.folder_open_outlined, 'Arquivos', Colors.brown),
    ];
  }

  Widget _cardItem(BuildContext context, IconData icon, String label, Color color, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap ?? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Módulo $label em desenvolvimento'))),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              label, 
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, AuthProvider auth) {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          await auth.logout();
          if (!context.mounted) return;
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.power_settings_new, color: Colors.red),
        label: const Text('Sair da Conta', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
