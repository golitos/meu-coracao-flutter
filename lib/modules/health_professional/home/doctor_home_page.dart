import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/supabase_client.dart';
import '../../../models/form_record_model.dart';
import '../../patient/forms/form_detail_page.dart';

// Tela principal do Profissional de Saúde
// Tradução direta de HomeMedico.js com ordenação de prioridade clínica
class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _formsWithPatient = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctorDashboard();
  }

  // Carrega os registros dos pacientes vinculados ao médico
  Future<void> _fetchDoctorDashboard() async {
    final doctorId = supabase.auth.currentUser?.id;
    if (doctorId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Busca os formulários com o nome do paciente via JOIN da tabela profiles
      final response = await supabase
          .from('forms')
          .select('*, profiles:user_id(name)')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      // Converte e organiza a lista
      List<Map<String, dynamic>> list = data.map((item) {
        final form = FormRecordModel.fromJson(item);
        final patientName =
            item['profiles'] != null && item['profiles']['name'] != null
                ? item['profiles']['name'].toString()
                : 'Paciente';
        return {
          'form': form,
          'patientName': patientName,
        };
      }).toList();

      // Regra de triagem clínica do código original:
      // Não respondidos vêm primeiro (mais antigos primeiro para prioridade de fila);
      // Respondidos vêm depois (mais recentes primeiro).
      list.sort((a, b) {
        final formA = a['form'] as FormRecordModel;
        final formB = b['form'] as FormRecordModel;

        if (!formA.respondido && formB.respondido) return -1;
        if (formA.respondido && !formB.respondido) return 1;

        if (!formA.respondido && !formB.respondido) {
          return formA.createdAt.compareTo(formB.createdAt);
        }

        return formB.createdAt.compareTo(formA.createdAt);
      });

      // Pega os 5 prioritários
      setState(() {
        _formsWithPatient = list.take(5).toList();
      });
    } catch (e) {
      debugPrint('Aviso ao carregar dashboard médico: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getGravityColor(String gravity) {
    switch (gravity) {
      case 'Grave':
        return Colors.red;
      case 'Moderado':
        return Colors.orange;
      case 'Leve':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final doctorName = authService.currentUser?.name?.isNotEmpty == true
        ? authService.currentUser!.name!
        : 'Profissional';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Painel do Profissional',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF353840),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD04556)))
          : RefreshIndicator(
              onRefresh: _fetchDoctorDashboard,
              color: const Color(0xFFD04556),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Boas-vindas
                    Text(
                      'Bem-vindo(a), $doctorName',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 16),

                    // Atalho: Visualizar todos os formulários
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black12),
                        ),
                      ),
                      icon:
                          const Icon(Icons.list_alt, color: Color(0xFFD04556)),
                      label: const Text('Visualizar todos os formulários',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        // Navega para a aba de formulários
                      },
                    ),
                    const SizedBox(height: 12),

                    // Atalho: Visualizar todos os pacientes
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black12),
                        ),
                      ),
                      icon: const Icon(Icons.person_search,
                          color: Color(0xFFD04556)),
                      label: const Text('Visualizar todos os pacientes',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        // Navega para a aba de busca de pacientes
                      },
                    ),
                    const SizedBox(height: 24),

                    // Título da Lista
                    const Text(
                      'Últimos registros de pacientes',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 12),

                    if (_formsWithPatient.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Nenhum formulário pendente de avaliação.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    else
                      // Lista de registros prioritários
                      ..._formsWithPatient.map((item) {
                        final form = item['form'] as FormRecordModel;
                        final patientName = item['patientName'] as String;
                        final gravityColor =
                            _getGravityColor(form.gravityLevel);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormDetailPage(
                                    formRecord: form,
                                    isDoctorView:
                                        true, // Visão do médico (permite responder)
                                  ),
                                ),
                              );
                              if (updated == true) _fetchDoctorDashboard();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        patientName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87),
                                      ),
                                      Text(
                                        '${form.createdAt.day.toString().padLeft(2, '0')}/${form.createdAt.month.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                            color: Colors.black45,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.circle,
                                          size: 12, color: gravityColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Risco: ${form.gravityLevel}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: gravityColor),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: form.respondido
                                              ? Colors.green.withOpacity(0.12)
                                              : const Color(0xFFD04556)
                                                  .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          form.respondido
                                              ? 'Respondido'
                                              : 'Pendente',
                                          style: TextStyle(
                                            color: form.respondido
                                                ? Colors.green
                                                : const Color(0xFFD04556),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }
}
