import 'package:flutter/material.dart';

// Tela de gerenciamento da base de medicamentos geral do sistema
class MedicationBasePage extends StatelessWidget {
  const MedicationBasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        title: const Text('Base de Medicamentos',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF202225),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Catálogo global de medicamentos (SUS / Farmácia Popular / etc)',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE52246),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Aqui vai abrir a tela de cadastrar novo remédio na base
        },
      ),
    );
  }
}
