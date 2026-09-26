import 'package:flutter/material.dart';

// Tela que lista o histórico de formulários enviados pelo paciente
class PatientFormsListPage extends StatelessWidget {
  const PatientFormsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        title:
            const Text('Meus Registros', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF202225),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Histórico de Formulários Enviados',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
