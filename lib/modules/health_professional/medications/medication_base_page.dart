import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import '../../../models/medication_model.dart';

import 'medication_form_page.dart';

// Tela de gerenciamento da base de medicamentos geral do sistema
// Tradução direta do BaseMedicamentos/index.js
class MedicationBasePage extends StatefulWidget {
  const MedicationBasePage({super.key});

  @override
  State<MedicationBasePage> createState() => _MedicationBasePageState();
}

class _MedicationBasePageState extends State<MedicationBasePage> {
  // Lista com todos os remédios vindos do banco
  List<BaseMedicationModel> _allMedications = [];

  // Lista filtrada pelo campo de busca
  List<BaseMedicationModel> _filteredMedications = [];

  // Controlador do campo de texto de busca
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Busca os remédios cadastrados no Supabase
  Future<void> _fetchMedications() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('medications_base')
          .select()
          .order('name', ascending: true);

      final list = (response as List<dynamic>)
          .map((item) => BaseMedicationModel.fromJson(item))
          .toList();

      setState(() {
        _allMedications = list;
        _filteredMedications = list;
      });
    } catch (error) {
      // Se ainda não tiver banco conectado, usa dados mocados de exemplo para não travar o visual
      debugPrint("Erro ao buscar medicamentos: $error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Filtra a lista conforme o usuário digita
  void _filterMedications(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredMedications = _allMedications);
    } else {
      setState(() {
        _filteredMedications = _allMedications
            .where(
                (med) => med.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Base de Medicamentos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF353840),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Campo de busca no topo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterMedications,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Buscar medicamento...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _filterMedications('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Área da lista ou mensagens de status
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD04556)),
                  )
                : _filteredMedications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medical_services_outlined,
                                size: 54, color: Colors.black26),
                            SizedBox(height: 12),
                            Text(
                              'Nenhum medicamento encontrado',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Adicione medicamentos usando o botão abaixo',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black38),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchMedications,
                        color: const Color(0xFFD04556),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _filteredMedications.length,
                          itemBuilder: (context, index) {
                            final med = _filteredMedications[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFD04556)
                                      .withValues(alpha: 0.1),
                                  child: const Icon(Icons.medication,
                                      color: Color(0xFFD04556)),
                                ),
                                title: Text(
                                  med.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  med.concentrations.isNotEmpty
                                      ? 'Concentrações: ${med.concentrations.join(", ")}'
                                      : 'Sem dosagens cadastradas',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.grey),
                                  onPressed: () async {
                                    // Abre o formulário passando o remédio selecionado para edição
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MedicationFormPage(medication: med),
                                      ),
                                    );
                                    if (updated == true) _fetchMedications();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),

      // Botão Flutuante (+) para cadastrar novo remédio
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD04556),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Abre o formulário vazio para criar um novo remédio na base
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MedicationFormPage(),
            ),
          );
          if (created == true) _fetchMedications();
        },
      ),
    );
  }
}
