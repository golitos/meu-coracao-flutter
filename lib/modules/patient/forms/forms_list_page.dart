import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import '../../../models/form_record_model.dart';
import 'form_detail_page.dart';

// Ecrã de listagem do histórico de formulários clínicos do paciente
// Tradução direta de FormularioList/index.js
class PatientFormsListPage extends StatefulWidget {
  const PatientFormsListPage({super.key});

  @override
  State<PatientFormsListPage> createState() => _PatientFormsListPageState();
}

class _PatientFormsListPageState extends State<PatientFormsListPage> {
  List<FormRecordModel> _forms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchForms();
  }

  // Carrega todos os formulários enviados pelo paciente autenticado
  Future<void> _fetchForms() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('forms')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List<dynamic>)
          .map((item) => FormRecordModel.fromJson(item))
          .toList();

      setState(() {
        _forms = list;
      });
    } catch (e) {
      debugPrint('Aviso ao procurar formulários: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Retorna a cor correspondente à gravidade
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Meus Formulários',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF353840),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD04556)),
            )
          : _forms.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 64, color: Colors.black26),
                      SizedBox(height: 12),
                      Text(
                        'Nenhum formulário enviado',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Os seus registos clínicos concluídos aparecerão aqui',
                        style: TextStyle(fontSize: 14, color: Colors.black38),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchForms,
                  color: const Color(0xFFD04556),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _forms.length,
                    itemBuilder: (context, index) {
                      final item = _forms[index];
                      final gravity = item.gravityLevel;
                      final gravityColor = _getGravityColor(gravity);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FormDetailPage(
                                  formRecord: item,
                                  isDoctorView: false,
                                ),
                              ),
                            );
                            _fetchForms();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.circle,
                                            size: 12, color: gravityColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          gravity,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: gravityColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${item.createdAt.day.toString().padLeft(2, '0')}/${item.createdAt.month.toString().padLeft(2, '0')}/${item.createdAt.year}',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black45),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Dor no Peito: ${item.diagDorPeito}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Insuficiência Cardíaca: ${item.diagInsuficienciaCard}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          item.respondido
                                              ? Icons.check_circle
                                              : Icons.access_time,
                                          size: 16,
                                          color: item.respondido
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item.respondido
                                              ? 'Avaliado pelo profissional'
                                              : 'Aguardando avaliação',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: item.respondido
                                                ? Colors.green
                                                : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 14, color: Colors.black26),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
