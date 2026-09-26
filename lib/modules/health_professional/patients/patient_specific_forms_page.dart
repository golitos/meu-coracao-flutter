import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import '../../../models/form_record_model.dart';
import '../widgets/doctor_form_card.dart';

// Ecrã que lista o histórico de formulários de um paciente específico (Visão do Médico)
// Tradução direta de FormularioListPacientes/index.js
class PatientSpecificFormsPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientSpecificFormsPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientSpecificFormsPage> createState() =>
      _PatientSpecificFormsPageState();
}

class _PatientSpecificFormsPageState extends State<PatientSpecificFormsPage> {
  List<FormRecordModel> _forms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientForms();
  }

  // Busca apenas os formulários do paciente selecionado
  Future<void> _fetchPatientForms() async {
    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('forms')
          .select()
          .eq('user_id', widget.patientId)
          .order('created_at', ascending: false);

      final list = (response as List<dynamic>)
          .map((item) => FormRecordModel.fromJson(item))
          .toList();

      setState(() {
        _forms = list;
      });
    } catch (e) {
      debugPrint('Aviso ao obter histórico do paciente: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Registos: ${widget.patientName}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF353840),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD04556)))
                : _forms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.assignment_outlined,
                                size: 64, color: Colors.black26),
                            SizedBox(height: 12),
                            Text(
                              'Nenhum formulário encontrado',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchPatientForms,
                        color: const Color(0xFFD04556),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: _forms.length,
                          itemBuilder: (context, index) {
                            final form = _forms[index];

                            // Reutiliza o card do médico que criámos anteriormente
                            return DoctorFormCard(
                              form: form,
                              patientName: widget.patientName,
                              onRefresh: _fetchPatientForms,
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
