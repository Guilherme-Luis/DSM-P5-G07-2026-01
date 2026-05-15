import 'dart:io';
import '../core/api_client.dart';

class AppFile {
  final String id;
  final String name;
  final String url;
  final String? type;

  AppFile({
    required this.id,
    required this.name,
    required this.url,
    this.type,
  });

  factory AppFile.fromJson(Map<String, dynamic> json) {
    return AppFile(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      type: json['type'],
    );
  }
}

class FileService {
  final ApiClient api;

  FileService(this.api);

  Future<List<AppFile>> listAllFiles() async {
    final response = await api.get('/files');
    final List data = response is List ? response : (response['files'] ?? []);
    return data.map((e) => AppFile.fromJson(e)).toList();
  }

  Future<void> uploadFile(File file) async {
    await api.postMultipart(
      '/files',
      {},
      file: file,
      fileField: 'file',
    );
  }

  Future<void> deleteFile(String id) async {
    await api.delete('/files/$id');
  }

  String getDownloadUrl(String id) {
    return '${api.baseUrl}/files/$id/download';
  }
}
