class AppUser {
  final String id;
  final String name;
  final String email;
  final String? role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
    );
  }
}