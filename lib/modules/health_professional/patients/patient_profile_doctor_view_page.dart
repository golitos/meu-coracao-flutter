import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import 'patient_specific_forms_page.dart';
import 'patient_edit_by_doctor_page.dart';

// Prontuário do Paciente visto pelo Médico
// Tradução direta de PerfilPacienteM/index.js
class PatientProfileDoctorViewPage extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const PatientProfileDoctorViewPage({
    super.key,
    required this.patientData,
  });

  @override
  State<PatientProfileDoctorViewPage> createState() =>
      _PatientProfileDoctorViewPageState();
}

class _PatientProfileDoctorViewPageState
    extends State<PatientProfileDoctorViewPage> {
  String? _avatarUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientAvatar();
  }

  // Carrega o avatar atualizado do paciente
  Future<void> _loadPatientAvatar() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', widget.patientData['id'])
          .maybeSingle();

      if (response != null && response['avatar_url'] != null) {
        setState(() {
          _avatarUrl = response['avatar_url'];
        });
      }
    } catch (e) {
      debugPrint('Aviso ao carregar avatar do paciente: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patientData['name'] ?? 'Paciente';

    return Scaffold(
      backgroundColor: const Color(0xFF353840),
      appBar: AppBar(
        title: Text(
          patientName,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF202225),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE52246)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Fotografia de Perfil do Paciente
                  CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.white24,
                    backgroundImage:
                        _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                    child: _avatarUrl == null
                        ? const Icon(Icons.person,
                            size: 80, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Nome do Paciente
                  Text(
                    patientName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF1F1F1),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Botão: Atualizar Perfil do Paciente
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52246),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'Atualizar perfil do paciente',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientEditByDoctorPage(
                              patientData: widget.patientData,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botão: Últimos Registos
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52246),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.assignment, color: Colors.white),
                      label: const Text(
                        'Últimos Registros',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientSpecificFormsPage(
                              patientId: widget.patientData['id'],
                              patientName: patientName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botão: Gerir Medicamentos
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52246),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.medication, color: Colors.white),
                      label: const Text(
                        'Gerenciar Medicamentos',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        // Encaminha para MedicationManagement/index.js passando o ID do paciente
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
