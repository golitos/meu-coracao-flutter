import 'package:flutter/material.dart';

// Tela que exibe as respostas do formulário e o parecer do médico
class FormDetailPage extends StatelessWidget {
  const FormDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        title: const Text('Detalhes do Registro',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF202225),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'Respostas do paciente e feedback do médico',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
