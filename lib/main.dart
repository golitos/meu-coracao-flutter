import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/auth_service.dart';
import 'core/supabase_client.dart';
import 'routes/app_routes.dart';

void main() async {
  // Garante que o motor do Flutter esteja pronto antes de carregar plugins nativos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Supabase (enquanto não temos as chaves oficiais, roda protegido)
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint(
        'Aviso: Supabase ainda não configurado com credenciais reais: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        // Disponibiliza o serviço de autenticação para todo o app
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MeuCoracaoApp(),
    ),
  );
}

class MeuCoracaoApp extends StatelessWidget {
  const MeuCoracaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Coração',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFE52246),
        scaffoldBackgroundColor: const Color(0xFF36393F),
        useMaterial3: true,
      ),
      home: const AppRouter(),
    );
  }
}
