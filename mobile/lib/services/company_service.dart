import 'dart:io';
import '../core/api_client.dart';
import '../models/company.dart';

class CompanyService {
  final ApiClient api;

  CompanyService(this.api);

  Future<List<Company>> listCompanies() async {
    final response = await api.get('/companies');
    
    final List data = response is List 
        ? response 
        : (response is Map ? (response['companies'] ?? response['items'] ?? []) : []);
        
    return data.map((e) => Company.fromJson(e)).toList();
  }

  Future<void> createCompany({
    required String name,
    required String cnpj,
    required String email,
    required String phone,
    File? image,
  }) async {
    await api.postMultipart(
      '/companies',
      {
        'name': name,
        'cnpj': cnpj,
        'email': email,
        'phone': phone,
      },
      file: image,
      fileField: 'image',
    );
  }

  Future<void> updateCompany(String id, {String? phone, File? image}) async {
    if (image != null) {
      await api.postMultipart(
        '/companies/$id',
        {'phone': phone ?? ''},
        file: image,
        fileField: 'image',
      );
    } else {
      await api.patch('/companies/$id', body: {'phone': phone});
    }
  }

  Future<void> deleteCompany(String id) async {
    await api.delete('/companies/$id');
  }
}
