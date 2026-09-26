import 'package:flutter/material.dart';

// Tela de busca de pacientes por nome/CPF/prontuário
class PatientSearchPage extends StatelessWidget {
  const PatientSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        title: const Text('Buscar Pacientes',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF202225),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Campo de busca e lista de pacientes vinculados',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
