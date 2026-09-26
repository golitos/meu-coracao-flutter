import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/supabase_client.dart';
import 'patient_edit_profile_page.dart';

// Tela de exibição do perfil do paciente com foto e logout
// Tradução direta de ProfilePaciente.js
class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? _avatarUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Carrega a URL da foto de perfil direto do Supabase
  Future<void> _loadProfileData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', userId)
          .maybeSingle();

      if (data != null && data['avatar_url'] != null) {
        setState(() {
          _avatarUrl = data['avatar_url'];
        });
      }
    } catch (e) {
      debugPrint('Aviso ao carregar avatar: $e');
    }
  }

  // Escolhe imagem da galeria e faz upload no bucket 'avatars'
  Future<void> _pickAndUploadImage() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final fileBytes = await File(picked.path).readAsBytes();
      final storagePath = 'profile_$userId.jpg';

      // Salva no storage (sobrescrevendo foto antiga)
      await supabase.storage.from('avatars').uploadBinary(
            storagePath,
            fileBytes,
          );

      final publicUrl =
          supabase.storage.from('avatars').getPublicUrl(storagePath);

      // Atualiza o link no perfil do usuário
      await supabase.from('profiles').update({
        'avatar_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      setState(() {
        _avatarUrl = publicUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    final email = supabase.auth.currentUser?.email ?? user?.email ?? '';
    final name = user?.name?.isNotEmpty == true ? user!.name! : 'Paciente';

    return Scaffold(
      backgroundColor: const Color(0xFF353840),
      appBar: AppBar(
        title: const Text('Meu Perfil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF202225),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 30.0),
                child: Column(
                  children: [
                    // Botão da Foto de Perfil com botão "+" de alterar
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: CircleAvatar(
                              radius: 75,
                              backgroundColor: Colors.white24,
                              backgroundImage: _avatarUrl != null
                                  ? NetworkImage(_avatarUrl!)
                                  : null,
                              child: _avatarUrl == null
                                  ? const Icon(Icons.person,
                                      size: 80, color: Colors.white70)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: GestureDetector(
                              onTap: _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD04556),
                                  shape: BoxShape.circle,
                                ),
                                child: _isUploadingPhoto
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.add_a_photo,
                                        color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nome e E-mail
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF1F1F1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Botão Atualizar Perfil
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDDDDDD),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PatientEditProfilePage(),
                            ),
                          );
                          if (updated == true) {
                            _loadProfileData();
                          }
                        },
                        child: const Text(
                          'Atualizar perfil',
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Botão Sair (Logout)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4040),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => authService.signOut(),
                        child: const Text(
                          'Sair',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Rodapé de Créditos Institucionais do Projeto
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: const [
                  Text('Desenvolvido por: Gabriel Longhi Quadro',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  SizedBox(height: 2),
                  Text('Continuado por: Edmundo Meyer',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
