import 'dart:io';
import '../core/api_client.dart';
import '../models/product.dart';

class ProductService {
  final ApiClient api;

  ProductService(this.api);

  Product _parseProductResponse(dynamic response) {
    if (response is Map && response.containsKey('product')) {
      return Product.fromJson(response['product']);
    }
    return Product.fromJson(response);
  }

  Future<List<Product>> listProducts() async {
    final response = await api.get('/products');
    final List data = response is List
        ? response
        : (response['products'] ?? response['items'] ?? []);
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    File? image,
  }) async {
    final response = await api.postMultipart(
      '/products',
      {
        'name': name,
        'description': description,
        'price': price.toString(),
        'stock': stock.toString(),
      },
      file: image,
      fileField: 'image',
    );
    return _parseProductResponse(response);
  }

  Future<Product> updateProduct(String id, {
    String? name,
    String? description,
    double? price,
    int? stock,
    File? image,
    bool? active,
  }) async {
    if (image != null) {
      final fields = <String, String>{};
      if (name != null) fields['name'] = name;
      if (description != null) fields['description'] = description;
      if (price != null) fields['price'] = price.toString();
      if (stock != null) fields['stock'] = stock.toString();
      if (active != null) fields['active'] = active.toString();

      final response = await api.multipartRequest('PUT', '/products/$id', fields, file: image);
      return _parseProductResponse(response);
    } else {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (price != null) body['price'] = price;
      if (stock != null) body['stock'] = stock;
      if (active != null) body['active'] = active;

      final response = await api.put('/products/$id', body: body);
      return _parseProductResponse(response);
    }
  }

  Future<Product> toggleProduct(String id) async {
    final response = await api.patch('/products/$id/toggle');
    return _parseProductResponse(response);
  }
}
