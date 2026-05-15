import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool loading = false;

  Future<void> _finishPurchase() async {
    setState(() => loading = true);

    try {
      final cart = context.read<CartProvider>();
      final orderService = context.read<OrderService>();
      await orderService.createOrder(cart.items);
      cart.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra concluída com sucesso')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao finalizar compra: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Itens: ${cart.totalItems}'),
            const SizedBox(height: 8),
            Text('Total: R\$ ${cart.total.toStringAsFixed(2)}'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _finishPurchase,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Confirmar compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}