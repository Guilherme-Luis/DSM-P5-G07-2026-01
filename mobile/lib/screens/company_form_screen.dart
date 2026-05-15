import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/company.dart';
import '../services/company_service.dart';
import '../providers/companies_provider.dart';

class CompanyFormScreen extends StatefulWidget {
  final Company? company;
  const CompanyFormScreen({super.key, this.company});

  @override
  State<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  File? _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _nameCtrl.text = widget.company!.name;
      _cnpjCtrl.text = _formatCnpj(widget.company!.cnpj);
      _emailCtrl.text = widget.company!.email;
      _phoneCtrl.text = _formatPhone(widget.company!.phone);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cnpjCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _formatCnpj(String cnpj) {
    cnpj = cnpj.replaceAll(RegExp(r'\D'), '');
    if (cnpj.length > 14) cnpj = cnpj.substring(0, 14);
    var formatted = '';
    for (var i = 0; i < cnpj.length; i++) {
      if (i == 2 || i == 5) formatted += '.';
      if (i == 8) formatted += '/';
      if (i == 12) formatted += '-';
      formatted += cnpj[i];
    }
    return formatted;
  }

  String _formatPhone(String phone) {
    phone = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.length > 11) phone = phone.substring(0, 11);
    var formatted = '';
    for (var i = 0; i < phone.length; i++) {
      if (i == 0) formatted += '(';
      if (i == 2) formatted += ') ';
      if (i == 6 && phone.length <= 10) formatted += '-';
      if (i == 7 && phone.length == 11) formatted += '-';
      formatted += phone[i];
    }
    return formatted;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final provider = context.read<CompaniesProvider>();

      // Limpa as máscaras antes de enviar para a API
      final cnpjClean = _cnpjCtrl.text.replaceAll(RegExp(r'\D'), '');
      final phoneClean = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');

      if (widget.company == null) {
        await provider.addCompany(
          name: _nameCtrl.text.trim(),
          cnpj: cnpjClean,
          email: _emailCtrl.text.trim(),
          phone: phoneClean,
          image: _image,
        );
      } else {
        await provider.updateCompany(
          widget.company!.id,
          phone: phoneClean,
          image: _image,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.company == null ? 'Empresa cadastrada!' : 'Empresa atualizada!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.company != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Empresa' : 'Nova Empresa')),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _image != null 
                        ? ClipOval(child: Image.file(_image!, fit: BoxFit.cover))
                        : (isEditing && widget.company!.imageUrl != null)
                          ? ClipOval(
                              child: Image.network(
                                widget.company!.imageUrl!, 
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 40),
                              ),
                            )
                          : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Empresa',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isEditing,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nome é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cnpjCtrl,
                    decoration: const InputDecoration(
                      labelText: 'CNPJ',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                      hintText: '00.000.000/0001-00',
                    ),
                    enabled: !isEditing,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CnpjInputFormatter(),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'CNPJ é obrigatório';
                      if (v.replaceAll(RegExp(r'\D'), '').length != 14) return 'CNPJ incompleto';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isEditing,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'E-mail é obrigatório';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                      hintText: '(00) 00000-0000',
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      PhoneInputFormatter(),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Telefone é obrigatório';
                      final digits = v.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 10) return 'Telefone muito curto';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(isEditing ? 'Salvar Alterações' : 'Cadastrar Empresa'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
  
  bool get loading => _loading;
}

class CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 14) text = text.substring(0, 14);
    var formatted = '';
    for (var i = 0; i < text.length; i++) {
      if (i == 2 || i == 5) formatted += '.';
      if (i == 8) formatted += '/';
      if (i == 12) formatted += '-';
      formatted += text[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 11) text = text.substring(0, 11);
    var formatted = '';
    for (var i = 0; i < text.length; i++) {
      if (i == 0) formatted += '(';
      if (i == 2) formatted += ') ';
      if (i == 6 && text.length <= 10) formatted += '-';
      if (i == 7 && text.length == 11) formatted += '-';
      formatted += text[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
