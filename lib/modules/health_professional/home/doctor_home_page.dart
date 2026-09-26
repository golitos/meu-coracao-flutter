import 'package:flutter/material.dart';

// Home do Médico: mostra formulários recentes com foco nos "não respondidos"
class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        title: const Text('Painel do Profissional',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF202225),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Home do Médico: Formulários prioritários e alertas',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
