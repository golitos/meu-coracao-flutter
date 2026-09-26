import 'package:supabase_flutter/supabase_flutter.dart';

/// Ponto de acesso global à instância do cliente Supabase.
/// Facilita chamadas de autenticação e consultas em qualquer parte do app.
final supabase = Supabase.instance.client;

class SupabaseConfig {
  // URLs e chaves públicas de acesso ao projeto Supabase
  // Podem ser substituídas pelas chaves do projeto oficial assim que o colega passar
  static const String url = 'https://SEU_PROJETO.supabase.co';
  static const String anonKey = 'SUA_ANON_KEY_AQUI';

  /// Inicializa a conexão com o Supabase antes da subida da interface do Flutter
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
