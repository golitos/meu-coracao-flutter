import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import '../../../models/user_model.dart';
import 'patient_profile_doctor_view_page.dart';

// Ecrã de pesquisa e listagem de pacientes vinculados ao profissional de saúde
// Tradução direta de Search/index.js
class PatientSearchPage extends StatefulWidget {
  const PatientSearchPage({super.key});

  @override
  State<PatientSearchPage> createState() => _PatientSearchPageState();
}

class _PatientSearchPageState extends State<PatientSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Carrega da base de dados os pacientes associados a este profissional
  Future<void> _fetchPatients() async {
    final doctorId = supabase.auth.currentUser?.id;
    if (doctorId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('doctor_id', doctorId)
          .eq('is_doctor', false)
          .order('name', ascending: true);

      final list = List<Map<String, dynamic>>.from(response);

      setState(() {
        _allPatients = list;
        _filteredPatients = list;
      });
    } catch (e) {
      debugPrint('Aviso ao obter lista de pacientes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Filtra em memória conforme o médico digita o nome
  void _filterPatients(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredPatients = _allPatients);
    } else {
      setState(() {
        _filteredPatients = _allPatients.where((patient) {
          final name = (patient['name'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF353840),
      appBar: AppBar(
        title: const Text(
          'Meus Pacientes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF353840),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Campo de Pesquisa
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterPatients,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Digite o nome do paciente...',
                  hintStyle: const TextStyle(color: Colors.black45),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFFE52246)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () {
                            _searchController.clear();
                            _filterPatients('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Lista de Pacientes
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE52246)),
                  )
                : _filteredPatients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.person_off_outlined,
                                size: 64, color: Colors.white24),
                            SizedBox(height: 12),
                            Text(
                              'Nenhum paciente encontrado',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchPatients,
                        color: const Color(0xFFE52246),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
                            final name = patient['name'] ?? 'Paciente sem nome';
                            final phone = patient['phone'] ?? 'Sem telefone';
                            final surgery =
                                patient['surgery_type'] ?? 'Não especificada';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              color: const Color(0xFF2C2F36),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      const Color(0xFFE52246).withOpacity(0.2),
                                  child: const Icon(Icons.person,
                                      color: Color(0xFFE52246)),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  'Cirurgia: $surgery | Tel: $phone',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 13),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white30, size: 16),
                                onTap: () {
                                  // Navega para o prontuário completo do paciente
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PatientProfileDoctorViewPage(
                                              patientData: patient),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
