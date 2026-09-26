import 'package:flutter/foundation.dart';
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

  /// Encerra a sessão atual
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await supabase.auth.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}
