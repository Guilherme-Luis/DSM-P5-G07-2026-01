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
    String parseId(dynamic id) {
      if (id == null) return '';
      if (id is String) return id;
      if (id is Map) return (id[r'$oid'] ?? id['id'] ?? id['_id'] ?? id.toString()).toString();
      return id.toString();
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
      id: parseId(json['id'] ?? json['_id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      cnpj: json['cnpj']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      imageUrl: extractImageUrl(json),
    );
  }
}
