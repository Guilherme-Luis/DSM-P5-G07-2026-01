import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/companies_provider.dart';
import '../models/company.dart'; // Certifique-se que o modelo está no caminho correto
import 'company_form_screen.dart';

class AdminCompaniesScreen extends StatefulWidget {
  const AdminCompaniesScreen({super.key});

  @override
  State<AdminCompaniesScreen> createState() => _AdminCompaniesScreenState();
}

class _AdminCompaniesScreenState extends State<AdminCompaniesScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega as empresas ao iniciar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompaniesProvider>().loadCompanies();
    });
  }

  /// Aplica a máscara de CNPJ: 00.000.000/0001-00
  String _formatCnpj(String cnpj) {
    cnpj = cnpj.replaceAll(RegExp(r'\D'), '');
    if (cnpj.length != 14) return cnpj; // Retorna sem máscara se for inválido
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Empresas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_outlined),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const CompanyFormScreen())
            ),
          )
        ],
      ),
      body: Consumer<CompaniesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.companies.isEmpty) {
            return const _CompaniesShimmer();
          }

          if (provider.error != null && provider.companies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.loadCompanies(),
                    child: const Text('Tentar Novamente'),
                  )
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadCompanies(),
            child: provider.companies.isEmpty
              ? const Center(child: Text('Nenhuma empresa cadastrada.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.companies.length,
                  itemBuilder: (context, index) {
                    final company = provider.companies[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(Icons.business, color: theme.colorScheme.primary),
                        ),
                        title: Text(
                          company.name, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Text(
                          'CNPJ: ${_formatCnpj(company.cnpj)}', // Máscara aplicada aqui
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDelete(context, company),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CompanyFormScreen(company: company)),
                          );
                        },
                      ),
                    );
                  },
                ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Company company) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Empresa?'),
        content: Text('Deseja remover a empresa ${company.name}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<CompaniesProvider>().deleteCompany(company.id);
                if (context.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir: $e'))
                  );
                }
              }
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, 
              foregroundColor: Colors.white
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _CompaniesShimmer extends StatelessWidget {
  const _CompaniesShimmer();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 8,
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: const SizedBox(height: 70, width: double.infinity),
        ),
      ),
    );
  }
}
