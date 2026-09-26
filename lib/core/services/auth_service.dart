import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../supabase_client.dart';
import '../../models/user_model.dart';

/// Controla o estado global de autenticação da aplicação.
/// Notifica os widgets ouvintes quando o usuário faz login, logout ou muda de perfil.
class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => supabase.auth.currentSession != null;
  bool get isDoctor => _currentUser?.isDoctor ?? false;

  AuthService() {
    _initAuthListener();
  }

  /// Escuta alterações no estado da sessão (login, logout, token refresh)
  void _initAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await _fetchUserProfile(session.user.id, session.user.email ?? '');
      } else {
        _currentUser = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Busca os dados complementares do usuário na tabela 'profiles'
  Future<void> _fetchUserProfile(String userId, String email) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _currentUser = UserModel.fromJson(response);
      } else {
        // Fallback caso o registro ainda não tenha campos extras na tabela
        _currentUser = UserModel(id: userId, email: email, isDoctor: false);
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil do usuário: $e');
      _currentUser = UserModel(id: userId, email: email, isDoctor: false);
    }
  }

  /// Inicia a sessão com email e senha
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // O _initAuthListener vai capturar a mudança de estado e carregar o perfil automaticamente
  }

  /// Encerra a sessão atual
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await supabase.auth.signOut();
    _currentUser = null;

    _isLoading = false;
    notifyListeners();
  }

  // --- MÉTODO PARA REGISTAR UM NOVO MÉDICO ---
  Future<void> signUpMedico({
    required String email,
    required String password,
    required String name,
    required String crm,
    required String state,
  }) async {
    // 1. Cria o utilizador no Supabase Auth
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null)
      throw Exception('Falha ao criar a conta de autenticação.');

    // 2. Guarda os dados específicos do médico na tabela 'profiles'
    await supabase.from('profiles').insert({
      'id': user.id,
      'email': email,
      'name': name,
      'crm': crm,
      'state': state,
      'is_doctor': true,
      'created_at': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  // --- MÉTODO PARA REGISTAR UM NOVO PACIENTE ---
  Future<void> signUpPaciente({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String motherName,
    required String sex,
    required String doctorId,
    required int birthDay,
    required int birthMonth,
    required int birthYear,
  }) async {
    // 1. Cria o utilizador no Supabase Auth
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null)
      throw Exception('Falha ao criar a conta de autenticação.');

    // 2. Guarda os dados específicos do paciente na tabela 'profiles'
    await supabase.from('profiles').insert({
      'id': user.id,
      'email': email,
      'name': name,
      'phone': phone,
      'mother_name': motherName,
      'sex': sex,
      'doctor_id': doctorId,
      'birth_day': birthDay,
      'birth_month': birthMonth,
      'birth_year': birthYear,
      'is_doctor': false,
      'created_at': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }
} // FIM DA CLASSE AUTHSERVICE
