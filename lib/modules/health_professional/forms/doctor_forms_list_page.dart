import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import '../../../models/form_record_model.dart';
import '../../patient/forms/form_detail_page.dart';

// Ecrã com a lista geral de formulários clínicos com filtros de gravidade e ordenação
// Tradução direta de FormularioListMedico/index.js
class DoctorFormsListPage extends StatefulWidget {
  const DoctorFormsListPage({super.key});

  @override
  State<DoctorFormsListPage> createState() => _DoctorFormsListPageState();
}

class _DoctorFormsListPageState extends State<DoctorFormsListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allForms = [];

  // Filtros ativos
  String _selectedGravity = 'Todos';
  String _sortingType = 'data'; // 'data' ou 'gravidade'

  final List<String> _gravityOptions = const [
    'Todos',
    'Grave',
    'Moderado',
    'Leve',
    'Tranquilo'
  ];

  @override
  void initState() {
    super.initState();
    _fetchForms();
  }

  // Carrega todos os formulários da base de dados com os dados do paciente
  Future<void> _fetchForms() async {
    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('forms')
          .select('*, profiles:user_id(name)')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      final list = data.map((item) {
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

      setState(() {
        _allForms = list;
      });
    } catch (e) {
      debugPrint('Aviso ao obter formulários: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Determina a pior gravidade entre dor no peito e insuficiência cardíaca
  String _getWorstGravity(FormRecordModel form) {
    const gravityOrder = {'Grave': 1, 'Moderado': 2, 'Leve': 3, 'Tranquilo': 4};
    final gravDor = gravityOrder[form.diagDorPeito] ?? 5;
    final gravInsuf = gravityOrder[form.diagInsuficienciaCard] ?? 5;

    final worst = gravDor < gravInsuf ? gravDor : gravInsuf;
    if (worst == 1) return 'Grave';
    if (worst == 2) return 'Moderado';
    if (worst == 3) return 'Leve';
    if (worst == 4) return 'Tranquilo';
    return 'Tranquilo';
  }

  int _gravityWeight(String gravity) {
    switch (gravity) {
      case 'Grave':
        return 1;
      case 'Moderado':
        return 2;
      case 'Leve':
        return 3;
      case 'Tranquilo':
        return 4;
      default:
        return 5;
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

  // Aplica filtros e ordenação aos dados
  List<Map<String, dynamic>> _getProcessedForms() {
    var filtered = _allForms.where((item) {
      if (_selectedGravity == 'Todos') return true;
      final form = item['form'] as FormRecordModel;
      return _getWorstGravity(form) == _selectedGravity;
    }).toList();

    filtered.sort((a, b) {
      final formA = a['form'] as FormRecordModel;
      final formB = b['form'] as FormRecordModel;

      // Prioridade primária: não respondidos surgem sempre em primeiro lugar
      if (!formA.respondido && formB.respondido) return -1;
      if (formA.respondido && !formB.respondido) return 1;

      // Critério secundário: gravidade
      if (_sortingType == 'gravidade') {
        final gravA = _gravityWeight(_getWorstGravity(formA));
        final gravB = _gravityWeight(_getWorstGravity(formB));
        if (gravA != gravB) return gravA.compareTo(gravB);
      }

      // Critério padrão: cronológico
      if (!formA.respondido && !formB.respondido) {
        return formA.createdAt.compareTo(formB.createdAt);
      }
      return formB.createdAt.compareTo(formA.createdAt);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final displayForms = _getProcessedForms();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Triagens e Formulários',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF353840),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Bloco de Filtros
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                // Filtro por Gravidade
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mostrar:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGravity,
                            isExpanded: true,
                            items: _gravityOptions.map((opt) {
                              return DropdownMenuItem(
                                value: opt,
                                child: Text(opt,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null)
                                setState(() => _selectedGravity = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Ordenação
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ordenar por:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortingType,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                  value: 'data',
                                  child: Text('Data',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87))),
                              DropdownMenuItem(
                                  value: 'gravidade',
                                  child: Text('Gravidade',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87))),
                            ],
                            onChanged: (val) {
                              if (val != null)
                                setState(() => _sortingType = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de Formulários
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD04556)))
                : displayForms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.assignment_outlined,
                                size: 64, color: Colors.black26),
                            SizedBox(height: 12),
                            Text(
                              'Nenhum registo encontrado',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchForms,
                        color: const Color(0xFFD04556),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: displayForms.length,
                          itemBuilder: (context, index) {
                            final item = displayForms[index];
                            final form = item['form'] as FormRecordModel;
                            final patientName = item['patientName'] as String;
                            final worstGravity = _getWorstGravity(form);
                            final gravityColor = _getGravityColor(worstGravity);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
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
                                        isDoctorView: true,
                                      ),
                                    ),
                                  );
                                  if (updated == true) _fetchForms();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            '${form.createdAt.day.toString().padLeft(2, '0')}/${form.createdAt.month.toString().padLeft(2, '0')}/${form.createdAt.year}',
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
                                            'Risco: $worstGravity',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: gravityColor,
                                                fontSize: 14),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: form.respondido
                                                  ? Colors.green
                                                      .withOpacity(0.12)
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
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
