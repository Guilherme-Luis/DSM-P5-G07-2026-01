import 'dart:io';
import 'package:flutter/material.dart';
import '../models/company.dart';
import '../services/company_service.dart';

class CompaniesProvider extends ChangeNotifier {
  final CompanyService companyService;

  List<Company> _companies = [];
  bool _isLoading = false;
  String? _error;

  CompaniesProvider({required this.companyService});

  List<Company> get companies => _companies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCompanies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _companies = await companyService.listCompanies();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCompany({
    required String name,
    required String cnpj,
    required String email,
    required String phone,
    File? image,
  }) async {
    try {
      await companyService.createCompany(
        name: name,
        cnpj: cnpj,
        email: email,
        phone: phone,
        image: image,
      );
      await loadCompanies();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCompany(String id, {String? phone, File? image}) async {
    try {
      await companyService.updateCompany(id, phone: phone, image: image);
      await loadCompanies();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCompany(String id) async {
    try {
      await companyService.deleteCompany(id);
      _companies.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
