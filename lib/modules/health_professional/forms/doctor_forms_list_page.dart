import 'package:flutter/material.dart';

// Lista geral de formulários enviados por todos os pacientes (com filtro por gravidade)
class DoctorFormsListPage extends StatelessWidget {
  const DoctorFormsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        title: const Text('Triagens e Formulários',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF202225),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Lista geral com filtros: Tranquilo, Baixo, Moderado, Grave',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
