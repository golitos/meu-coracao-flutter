import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';

// Perfil do médico/profissional de saúde
class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        title: const Text('Perfil Profissional',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF202225),
        elevation: 0,
        actions: [
          // Botão de deslogar
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Dados do Profissional de Saúde',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
