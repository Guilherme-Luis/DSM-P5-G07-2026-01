import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';
import '../providers/auth_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product; 
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  
  File? _image;
  bool _loading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameCtrl.text = widget.product!.name;
      _descCtrl.text = widget.product!.description;
      _priceCtrl.text = widget.product!.price.toString();
      _stockCtrl.text = widget.product!.stock.toString();
      _isActive = widget.product!.active;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final productsProvider = context.read<ProductsProvider>();

      if (widget.product == null) {
        await productsProvider.addProduct(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: double.parse(_priceCtrl.text),
          stock: int.parse(_stockCtrl.text),
          image: _image,
        );
      } else {
        await productsProvider.updateProduct(
          widget.product!.id,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: double.parse(_priceCtrl.text),
          stock: int.parse(_stockCtrl.text),
          image: _image,
          active: _isActive,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.product == null ? 'Produto criado!' : 'Produto atualizado!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Produto' : 'Novo Produto')),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _image != null 
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : (isEditing && widget.product!.imageUrl != null)
                          ? Image.network(
                              widget.product!.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.broken_image, size: 40),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 40),
                                Text('Selecionar Imagem'),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nome do Produto'),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceCtrl,
                          decoration: const InputDecoration(labelText: r'Preço (R$)'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stockCtrl,
                          decoration: const InputDecoration(labelText: 'Estoque'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Produto Ativo'),
                    subtitle: const Text('Define se o produto está disponível para venda'),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Salvar Produto'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
