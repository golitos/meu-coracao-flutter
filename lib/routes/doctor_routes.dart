import 'package:flutter/material.dart';
import '../modules/health_professional/home/doctor_home_page.dart';
import '../modules/health_professional/forms/doctor_forms_list_page.dart';
import '../modules/health_professional/medications/medication_base_page.dart';
import '../modules/health_professional/patients/patient_search_page.dart';
import '../modules/health_professional/profile/doctor_profile_page.dart';

// Gerenciador de rotas do Médico/Profissional de Saúde quando está logado.
// Cria a barra inferior com as 5 abas principais do app legado.
class DoctorRoutes extends StatefulWidget {
  const DoctorRoutes({super.key});

  @override
  State<DoctorRoutes> createState() => _DoctorRoutesState();
}

class _DoctorRoutesState extends State<DoctorRoutes> {
  // Índice da aba atual (0 a 4)
  int _currentIndex = 0;

  // Telas vinculadas a cada uma das 5 abas
  final List<Widget> _tabs = const [
    DoctorHomePage(),
    DoctorFormsListPage(),
    MedicationBasePage(),
    PatientSearchPage(),
    DoctorProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF202225),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType
            .fixed, // Permite 5 abas sem quebrar o layout
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
            icon: Icon(Icons.medication_outlined),
            activeIcon: Icon(Icons.medication),
            label: 'Medicamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.person_search),
            label: 'Pacientes',
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
