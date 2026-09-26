/// Representa o perfil de usuário armazenado no banco de dados.
/// Define se a conta pertence a um Paciente ou a um Profissional de Saúde.
class UserModel {
  final String id;
  final String email;
  final String? name;
  final bool isDoctor; // true: Profissional de saúde, false: Paciente

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.isDoctor = false,
  });

  /// Converte o JSON vindo da tabela 'profiles'/'users' do Supabase em objeto Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      isDoctor: json['isDoctor'] ?? json['is_doctor'] ?? false,
    );
  }
}
