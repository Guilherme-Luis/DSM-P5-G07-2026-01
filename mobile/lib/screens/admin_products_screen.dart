import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import 'product_form_screen.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    if (!auth.isLoggedIn || auth.userRole != 'ADMIN') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acesso negado: Somente administradores.')),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductFormScreen()),
              ).then((_) => context.read<ProductsProvider>().loadProducts(silent: true));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProductsProvider>().loadProducts(),
        child: Consumer<ProductsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.products.isEmpty) {
              return const _AdminProductsShimmer();
            }

            if (provider.products.isEmpty) {
              return const Center(child: Text('Nenhum produto cadastrado.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.image_not_supported, color: Colors.grey),
                          )
                        : const Icon(Icons.image, size: 40),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('R\$ ${product.price.toStringAsFixed(2)} | Estoque: ${product.stock}'),
                        Text(
                          product.active ? 'Status: Ativo' : 'Status: Inativo',
                          style: TextStyle(
                            color: product.active ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: product.active ? 'Desativar Produto' : 'Ativar Produto',
                          child: Switch.adaptive(
                            value: product.active,
                            activeColor: Colors.green,
                            onChanged: (value) async {
                              bool confirm = true;
                              if (!value) {
                                confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Confirmar Desativação'),
                                    content: const Text('Tem certeza que deseja desativar este produto? Ele não ficará visível para os clientes.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('CANCELAR'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('DESATIVAR', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ) ?? false;
                              }

                              if (confirm) {
                                try {
                                  await provider.toggleProductActive(product.id);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro ao atualizar: $e')),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (_) => ProductFormScreen(product: product),
                               ),
                             ).then((_) => context.read<ProductsProvider>().loadProducts(silent: true));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AdminProductsShimmer extends StatelessWidget {
  const _AdminProductsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: SizedBox(height: 70, width: double.infinity),
        ),
      ),
    );
  }
}
