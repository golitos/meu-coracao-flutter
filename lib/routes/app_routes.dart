import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/auth_service.dart';

import 'auth_routes.dart';
import 'patient_routes.dart';
import 'doctor_routes.dart';

import '../modules/patient/forms/form_create_page.dart';
import '../modules/patient/forms/form_detail_page.dart';
import '../modules/patient/profile/patient_edit_profile_page.dart';

/// Widget guardião de rotas da aplicação (Roteador Central).
///
/// Ele substitui o antigo 'src/routes/index.js' do React Native,
/// decidindo qual fluxo de telas apresentar baseado no status de autenticação:
///   1. Enquanto verifica a sessão: Exibe indicador de carregamento.
///   2. Não autenticado: Exibe o fluxo de Login/Cadastro (AuthRoutes).
///   3. Autenticado como Profissional de Saúde: Exibe o fluxo do Médico (DocRoutes).
///   4. Autenticado como Paciente: Exibe o fluxo do Paciente (AppRoutes).
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta as alterações no estado de autenticação em tempo real
    final authService = context.watch<AuthService>();

    // 1. Estado de verificação de autenticação (Splash/Loading)
    if (authService.isLoading) {
      return const Scaffold(
        backgroundColor:
            Color(0xFF36393F), // Cor legada mantida para consistência
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE52246), // Vermelho legado do tema original
          ),
        ),
      );
    }

    // 2. Usuário não autenticado -> Fluxo de Autenticação
    if (!authService.isAuthenticated) {
      return const AuthRoutes();
    }

    // 3. Usuário autenticado como Profissional da Saúde (Médico/Enfermeiro)
    if (authService.isDoctor) {
      return const DoctorRoutes();
    }

    // 4. Usuário autenticado como Paciente
    return const PatientRoutes();
  }
}
