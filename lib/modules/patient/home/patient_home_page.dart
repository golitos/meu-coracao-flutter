import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/supabase_client.dart';
import '../../../models/form_record_model.dart';
import '../../../models/medication_model.dart';
import '../forms/form_create_page.dart';
import '../forms/form_detail_page.dart';

// Tela principal do Paciente
// Tradução direta do antigo Home/index.js
class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  bool _isLoading = true;
  FormRecordModel? _lastForm;
  List<PatientMedicationModel> _medications = [];
  bool _expandedMedications = false;

  @override
  void initState() {
    super.initState();
    _loadPatientDashboard();
  }

  // Carrega os dados do paciente (último formulário e medicamentos)
  Future<void> _loadPatientDashboard() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Busca o último formulário enviado pelo paciente
      final formResponse = await supabase
          .from('forms')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (formResponse != null) {
        _lastForm = FormRecordModel.fromJson(formResponse);
      }

      // 2. Busca os medicamentos receitados para este paciente
      final medsResponse = await supabase
          .from('patient_medications')
          .select()
          .eq('patient_id', userId)
          .order('created_at', ascending: false);

      _medications = (medsResponse as List<dynamic>)
          .map((m) => PatientMedicationModel.fromJson(m))
          .toList();
    } catch (e) {
      debugPrint('Aviso ao carregar dashboard: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Alterna o status se o paciente comprou/retirou o remédio
  Future<void> _togglePurchased(PatientMedicationModel med) async {
    final newStatus = !med.purchased;
    try {
      await supabase.from('patient_medications').update({
        'purchased': newStatus,
      }).eq('id', med.id);

      setState(() {
        final index = _medications.indexWhere((item) => item.id == med.id);
        if (index != -1) {
          _medications[index] = PatientMedicationModel(
            id: med.id,
            patientId: med.patientId,
            name: med.name,
            concentration: med.concentration,
            frequency: med.frequency,
            instructions: med.instructions,
            isFree: med.isFree,
            purchased: newStatus,
            createdAt: med.createdAt,
          );
        }
      });
    } catch (e) {
      debugPrint('Erro ao atualizar status de compra: $e');
    }
  }

  // Abre modal com detalhes e orientações do medicamento
  void _showMedicationDetails(PatientMedicationModel med) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                med.name,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              if (med.concentration != null)
                Text('Concentração: ${med.concentration}',
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black54)),
              if (med.frequency != null)
                Text('Posologia: ${med.frequency}',
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 12),
              const Text('Orientações e Cuidados:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(
                med.instructions ?? 'Nenhuma orientação específica cadastrada.',
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      med.purchased ? Colors.grey : const Color(0xFFD04556),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(
                    med.purchased ? Icons.check_circle : Icons.shopping_cart,
                    color: Colors.white),
                label: Text(
                  med.purchased
                      ? 'Medicamento já em posse'
                      : 'Marcar como Já Possuo',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _togglePurchased(med);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Cor do indicador de gravidade
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

  // Verifica se o último formulário tem mais de 7 dias
  bool _isOldRegistration() {
    if (_lastForm == null) return false;
    return DateTime.now().difference(_lastForm!.createdAt).inDays >= 7;
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final userName =
        authService.currentUser?.name?.split(' ').first ?? 'Paciente';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Meu Coração',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF353840),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD04556)))
          : RefreshIndicator(
              onRefresh: _loadPatientDashboard,
              color: const Color(0xFFD04556),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Saudação
                    Text(
                      'Olá, $userName',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 16),

                    // --- SEÇÃO: MEUS MEDICAMENTOS ---
                    Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Meus Medicamentos',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            if (_medications.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                    'Nenhum medicamento receitado ainda.',
                                    style: TextStyle(color: Colors.black54)),
                              )
                            else ...[
                              ...(_expandedMedications
                                      ? _medications
                                      : _medications.take(2))
                                  .map((med) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: med.purchased
                                        ? Colors.green.withOpacity(0.15)
                                        : const Color(0xFFD04556)
                                            .withOpacity(0.15),
                                    child: Icon(
                                      Icons.medication,
                                      color: med.purchased
                                          ? Colors.green
                                          : const Color(0xFFD04556),
                                    ),
                                  ),
                                  title: Text(med.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87)),
                                  subtitle: Text(
                                      med.concentration ?? 'Sem concentração',
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                  trailing: Wrap(
                                    spacing: 4,
                                    children: [
                                      if (med.isNew)
                                        const Chip(
                                          label: Text('NOVO',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white)),
                                          backgroundColor: Color(0xFFD04556),
                                          padding: EdgeInsets.zero,
                                        ),
                                      if (med.purchased)
                                        const Chip(
                                          label: Text('POSSUI',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white)),
                                          backgroundColor: Colors.green,
                                          padding: EdgeInsets.zero,
                                        ),
                                    ],
                                  ),
                                  onTap: () => _showMedicationDetails(med),
                                );
                              }),
                              if (_medications.length > 2)
                                TextButton(
                                  onPressed: () => setState(() =>
                                      _expandedMedications =
                                          !_expandedMedications),
                                  child: Text(
                                    _expandedMedications
                                        ? 'Mostrar menos'
                                        : 'Ver todos os medicamentos',
                                    style: const TextStyle(
                                        color: Color(0xFFD04556),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- SEÇÃO: ÚLTIMO REGISTRO CLÍNICO ---
                    Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Último Registro',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                if (_isOldRegistration())
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD04556),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Faça um novo registro',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_lastForm == null) ...[
                              const Text(
                                'Você ainda não registrou nenhuma informação sobre sua recuperação.',
                                style: TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD04556)),
                                icon: const Icon(Icons.description,
                                    color: Colors.white),
                                label: const Text('Fazer Primeiro Registro',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  // Abre a tela de responder formulário
                                },
                              ),
                            ] else ...[
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FormDetailPage(
                                        formRecord: _lastForm!,
                                        isDoctorView: false,
                                      ),
                                    ),
                                  );
                                },
                                // Card do último registro
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.circle,
                                                  size: 14,
                                                  color: _getGravityColor(
                                                      _lastForm!.gravityLevel)),
                                              const SizedBox(width: 6),
                                              Text(
                                                _lastForm!.gravityLevel,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _getGravityColor(
                                                      _lastForm!.gravityLevel),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${_lastForm!.createdAt.day}/${_lastForm!.createdAt.month}',
                                            style: const TextStyle(
                                                color: Colors.black45,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            _lastForm!.respondido
                                                ? Icons.check_circle
                                                : Icons.access_time,
                                            size: 16,
                                            color: _lastForm!.respondido
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _lastForm!.respondido
                                                ? 'Respondido pelo profissional'
                                                : 'Aguardando avaliação',
                                            style: TextStyle(
                                              color: _lastForm!.respondido
                                                  ? Colors.green
                                                  : Colors.black54,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_lastForm!.respondido &&
                                          _lastForm!.respostaMedico !=
                                              null) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border(
                                                left: BorderSide(
                                                    color: _getGravityColor(
                                                        _lastForm!
                                                            .gravityLevel),
                                                    width: 3)),
                                          ),
                                          child: Text(
                                            'Parecer: ${_lastForm!.respostaMedico}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      // Botão Flutuante (+) para responder o questionário
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD04556),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormCreatePage()),
          );
          if (result == true) {
            _loadPatientDashboard();
          }
        },
      ),
    );
  }
}
