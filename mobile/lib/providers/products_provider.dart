import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductService productService;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  ProductsProvider({required this.productService});

  List<Product> get products => _products; 
  
  /// Retorna apenas os produtos ativos para a vitrine do cliente
  List<Product> get activeProducts => _products.where((p) => p.active).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final newProducts = await productService.listProducts();
      _products = List<Product>.from(newProducts); 
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    File? image,
  }) async {
    try {
      final newProduct = await productService.createProduct(
        name: name,
        description: description,
        price: price,
        stock: stock,
        image: image,
      );
      _products.add(newProduct);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, {
    required String name,
    required String description,
    required double price,
    required int stock,
    File? image,
    bool? active,
  }) async {
    try {
      final updatedProduct = await productService.updateProduct(
        id,
        name: name,
        description: description,
        price: price,
        stock: stock,
        image: image,
        active: active,
      );
      
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleProductActive(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) return;

    try {
      // Sincroniza diretamente com o retorno da API
      final updatedProduct = await productService.toggleProduct(id);
      _products[index] = updatedProduct;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
