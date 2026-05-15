import '../core/api_constants.dart';

class Company {
  final String id;
  final String name;
  final String email;
  final String cnpj;
  final String phone;
  final String? imageUrl;

  Company({
    required this.id,
    required this.name,
    required this.email,
    required this.cnpj,
    required this.phone,
    this.imageUrl,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        return (value['id'] ?? value['_id'] ?? value['name'] ?? value.toString()).toString();
      }
      return value.toString();
    }

    String? extractImageUrl(Map<String, dynamic> json) {
      final String? fileId = json['imageId']?.toString() ?? 
                           json['image']?.toString() ?? 
                           json['imageUrl']?.toString();

      if (fileId == null || fileId.isEmpty) return null;

      if (fileId.startsWith('http')) return fileId;
      return '${ApiConstants.apiBase}/files/$fileId/download';
    }

    return Company(
      id: safeString(json['id'] ?? json['_id']),
      name: safeString(json['name']),
      email: safeString(json['email']),
      cnpj: safeString(json['cnpj']),
      phone: safeString(json['phone']),
      imageUrl: extractImageUrl(json),
    );
  }
}
