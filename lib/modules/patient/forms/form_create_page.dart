import 'package:flutter/material.dart';

// Tela onde o paciente responde o formulário e anexa fotos
class FormCreatePage extends StatelessWidget {
  const FormCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        title: const Text('Novo Formulário',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF202225),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'Perguntas do Sistema Especialista e envio de foto',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
