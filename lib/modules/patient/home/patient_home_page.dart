import 'package:flutter/material.dart';

// Tela principal do paciente (onde aparecem os remédios e resumo dos formulários)
class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        title: const Text('Meu Coração', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF202225),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Home do Paciente (Remédios e Status)',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      // Botão flutuante para facilitar responder um novo formulário
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE52246),
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Novo Registro', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.pushNamed(context, '/paciente/formulario-novo');
        },
      ),
    );
  }
}
