import 'package:flutter/material.dart';

// Tela para atualizar dados do paciente (telefone, cuidador, comorbidades, etc)
class PatientEditProfilePage extends StatelessWidget {
  const PatientEditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        title: const Text('Atualizar Perfil',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF202225),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'Campos de edição de dados clínicos e cadastrais',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
