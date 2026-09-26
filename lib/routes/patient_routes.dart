import 'package:flutter/material.dart';
import '../modules/patient/home/patient_home_page.dart';
import '../modules/patient/forms/forms_list_page.dart';
import '../modules/patient/profile/patient_profile_page.dart';

// Gerenciador de rotas do Paciente quando está logado.
// Cria a barra inferior (BottomNavigationBar) com 3 abas: Home, Lista e Perfil.
class PatientRoutes extends StatefulWidget {
  const PatientRoutes({super.key});

  @override
  State<PatientRoutes> createState() => _PatientRoutesState();
}

class _PatientRoutesState extends State<PatientRoutes> {
  // Índice da aba atualmente selecionada (0 = Home, 1 = Histórico, 2 = Perfil)
  int _currentIndex = 0;

  // Telas principais acessadas pelas abas inferiores
  final List<Widget> _tabs = const [
    PatientHomePage(),
    PatientFormsListPage(),
    PatientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Exibe a tela correspondente à aba ativa
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),

      // Barra de navegação inferior estilo escuro igual à do app original
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF202225),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            activeIcon: Icon(Icons.list_alt),
            label: 'Formulários',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
