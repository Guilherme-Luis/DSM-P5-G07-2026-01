import '../core/api_constants.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final bool active;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.active = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String? extractImageUrl(Map<String, dynamic> json) {
      final dynamic fileData = json['imageId'] ?? 
                               json['image_id'] ?? 
                               json['image'] ?? 
                               json['imageUrl'];

      if (fileData == null) return null;

      String fileId = '';
      if (fileData is String) {
        fileId = fileData;
      } else if (fileData is Map) {
        fileId = (fileData['id'] ?? fileData['_id'] ?? '').toString();
      }
      if (fileId.isEmpty) return null;
      if (fileId.startsWith('http')) return fileId;
      return '${ApiConstants.apiBase}/files/$fileId/download';
    }

    // Parsing robusto do campo 'active'
    final dynamic activeData = json['active'];
    bool isActive = true;
    if (activeData != null) {
      if (activeData is bool) isActive = activeData;
      else if (activeData is num) isActive = activeData == 1;
      else if (activeData is String) isActive = activeData.toLowerCase() == 'true' || activeData == '1';
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: extractImageUrl(json),
      active: isActive,
    );
  }
}
