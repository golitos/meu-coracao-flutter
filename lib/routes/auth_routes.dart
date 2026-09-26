import 'package:flutter/material.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/register_page.dart';

// Gerenciador de navegação das telas de quem NÃO está logado.
// Substitui o Stack.Navigator do auth.routes.js do React Native.
class AuthRoutes extends StatelessWidget {
  const AuthRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      // Rota que abre por padrão
      initialRoute: '/login',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/login':
            builder = (BuildContext _) => const LoginPage();
            break;
          case '/cadastrar':
            builder = (BuildContext _) => const RegisterPage();
            break;
          default:
            builder = (BuildContext _) => const LoginPage();
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}
