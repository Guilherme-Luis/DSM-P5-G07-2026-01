import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/file_service.dart';
import '../core/api_client.dart';

class AdminFilesScreen extends StatefulWidget {
  const AdminFilesScreen({super.key});

  @override
  State<AdminFilesScreen> createState() => _AdminFilesScreenState();
}

class _AdminFilesScreenState extends State<AdminFilesScreen> {
  late FileService _fileService;
  List<AppFile> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fileService = FileService(context.read<ApiClient>());
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    try {
      final files = await _fileService.listAllFiles();
      setState(() => _files = files);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _upload() async {
    final picker = ImagePicker();
    final picked = await picker.pickMedia();
    if (picked != null) {
      setState(() => _isLoading = true);
      try {
        await _fileService.uploadFile(File(picked.path));
        _loadFiles();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload concluído!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no upload: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Arquivos'),
        actions: [
          IconButton(icon: const Icon(Icons.upload_file), onPressed: _upload),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _files.length,
            itemBuilder: (context, index) {
              final file = _files[index];
              return ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(file.name),
                subtitle: Text(file.type ?? 'Arquivo'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _fileService.deleteFile(file.id);
                    _loadFiles();
                  },
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link: ${file.url}')));
                },
              );
            },
          ),
    );
  }
}
