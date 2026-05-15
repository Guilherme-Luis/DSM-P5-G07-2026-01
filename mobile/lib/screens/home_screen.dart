import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Box Ferreira'),
        actions: [
          const _CartButton(),
          const _UserMenuButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProductsProvider>().loadProducts(),
        child: Consumer<ProductsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.products.isEmpty) {
              return const _ProductsShimmer();
            }

            if (provider.error != null && provider.products.isEmpty) {
              return _ErrorState(error: provider.error!);
            }

            final activeProducts = provider.activeProducts;

            if (activeProducts.isEmpty) {
              return const Center(
                child: Text('Nenhum produto disponível no momento.'),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: activeProducts.length,
              itemBuilder: (_, index) {
                final product = activeProducts[index];
                return ProductCard(
                  key: ValueKey(product.id),
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  onAdd: () {
                    context.read<CartProvider>().addProduct(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} adicionado!'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const _BottomCartBanner(),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton();
  @override
  Widget build(BuildContext context) {
    final count = context.select<CartProvider, int>((c) => c.totalItems);
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }
}

class _UserMenuButton extends StatelessWidget {
  const _UserMenuButton();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) {
      return TextButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
        icon: const Icon(Icons.login),
        label: const Text('Entrar'),
      );
    }
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle, size: 30, color: Colors.green),
      onSelected: (value) async {
        if (value == 'profile') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
        } else if (value == 'logout') {
          await auth.logout();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: ListTile(leading: Icon(Icons.dashboard_outlined), title: Text('Minha Conta'), contentPadding: EdgeInsets.zero)),
        const PopupMenuItem(value: 'logout', child: ListTile(leading: Icon(Icons.exit_to_app, color: Colors.red), title: Text('Sair', style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
      ],
    );
  }
}

class _BottomCartBanner extends StatelessWidget {
  const _BottomCartBanner();
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.totalItems == 0) return const SizedBox.shrink();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: Text('Ver carrinho (${cart.totalItems}) - R\$ ${cart.total.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.read<ProductsProvider>().loadProducts(), child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}

class _ProductsShimmer extends StatelessWidget {
  const _ProductsShimmer();
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: 6,
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
