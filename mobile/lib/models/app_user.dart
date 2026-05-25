class AppUser {
  final String id;
  final String name;
  final String email;
  final String? role;

  AppUser({required this.id, required this.name, required this.email, this.role});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic id) {
      if (id == null) return '';
      if (id is String) return id;
      if (id is Map) return (id['\x24oid'] ?? id['id'] ?? id['_id'] ?? id.toString()).toString();
      return id.toString();
    }

    return AppUser(
      id: parseId(json['id'] ?? json['_id'] ?? json['userId']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString(),
    );
  }
}
