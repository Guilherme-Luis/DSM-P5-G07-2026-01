import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart'; // Importação explícita do modelo
import '../providers/orders_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrders();
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await context.read<OrdersProvider>().updateStatus(id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status atualizado!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
      }
    }
  }

  Future<void> _deleteOrder(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Pedido?'),
        content: const Text('Esta ação não pode ser desfeita.'),
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
        await context.read<OrdersProvider>().deleteOrder(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido excluído!')));
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
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão de Pedidos')),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.orders.isEmpty) {
            return Center(child: Text('Erro: ${provider.error}'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadOrders(),
            child: provider.orders.isEmpty
                ? const Center(child: Text('Nenhum pedido encontrado.'))
                : ListView.builder(
                    itemCount: provider.orders.length,
                    itemBuilder: (context, index) {
                      final order = provider.orders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ExpansionTile(
                          title: Text('Pedido #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}'),
                          subtitle: Text('Status: ${order.status} - Total: R\$ ${order.total.toStringAsFixed(2)}'),
                          children: [
                            ...order.items.map((OrderItemDetail item) => ListTile( // Tipagem explícita aqui
                              title: Text(item.product?.name ?? 'Produto removido'),
                              subtitle: Text('Quantidade: ${item.quantity}'),
                              trailing: Text('R\$ ${(item.price * item.quantity).toStringAsFixed(2)}'),
                            )),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  ActionChip(
                                    label: const Text('ENVIADO'),
                                    onPressed: () => _updateStatus(order.id, 'SHIPPED'),
                                  ),
                                  ActionChip(
                                    label: const Text('ENTREGUE'),
                                    backgroundColor: Colors.green[100],
                                    onPressed: () => _updateStatus(order.id, 'DELIVERED'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteOrder(order.id),
                                  ),
                                ],
                              ),
                            )
                          ],
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
