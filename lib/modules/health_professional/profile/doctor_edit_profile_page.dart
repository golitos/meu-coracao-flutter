import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';

// Tela de edição dos dados cadastrais do médico
// Tradução direta de AtualizarPerfilMedico/index.js
class DoctorEditProfilePage extends StatefulWidget {
  const DoctorEditProfilePage({super.key});

  @override
  State<DoctorEditProfilePage> createState() => _DoctorEditProfilePageState();
}

class _DoctorEditProfilePageState extends State<DoctorEditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _crmController = TextEditingController();

  String? _selectedState;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<Map<String, String>> _stateList = const [
    {'label': 'Acre', 'value': 'AC'},
    {'label': 'Alagoas', 'value': 'AL'},
    {'label': 'Amapá', 'value': 'AP'},
    {'label': 'Amazonas', 'value': 'AM'},
    {'label': 'Bahia', 'value': 'BA'},
    {'label': 'Ceará', 'value': 'CE'},
    {'label': 'Distrito Federal', 'value': 'DF'},
    {'label': 'Espírito Santo', 'value': 'ES'},
    {'label': 'Goiás', 'value': 'GO'},
    {'label': 'Maranhão', 'value': 'MA'},
    {'label': 'Mato Grosso', 'value': 'MT'},
    {'label': 'Mato Grosso do Sul', 'value': 'MS'},
    {'label': 'Minas Gerais', 'value': 'MG'},
    {'label': 'Pará', 'value': 'PA'},
    {'label': 'Paraíba', 'value': 'PB'},
    {'label': 'Paraná', 'value': 'PR'},
    {'label': 'Pernambuco', 'value': 'PE'},
    {'label': 'Piauí', 'value': 'PI'},
    {'label': 'Rio de Janeiro', 'value': 'RJ'},
    {'label': 'Rio Grande do Norte', 'value': 'RN'},
    {'label': 'Rio Grande do Sul', 'value': 'RS'},
    {'label': 'Rondônia', 'value': 'RO'},
    {'label': 'Roraima', 'value': 'RR'},
    {'label': 'Santa Catarina', 'value': 'SC'},
    {'label': 'São Paulo', 'value': 'SP'},
    {'label': 'Sergipe', 'value': 'SE'},
    {'label': 'Tocantins', 'value': 'TO'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _crmController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        _nameController.text = profile['name'] ?? '';
        _crmController.text = profile['crm'] ?? '';
        _selectedState = profile['state'];
      }
    } catch (e) {
      debugPrint('Aviso ao carregar dados do médico: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final userId = supabase.auth.currentUser?.id;

    try {
      await supabase.from('profiles').update({
        'name': _nameController.text.trim(),
        'crm': _crmController.text.trim(),
        'state': _selectedState,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Atualizar Perfil (Médico)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF353840),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD04556)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Nome é obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _crmController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        labelText: 'CRM',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'CRM é obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: const InputDecoration(
                        labelText: 'Estado de atuação',
                        border: OutlineInputBorder(),
                      ),
                      items: _stateList.map((state) {
                        return DropdownMenuItem<String>(
                          value: state['value'],
                          child: Text(state['label']!,
                              style: const TextStyle(color: Colors.black87)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedState = val),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD04556),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Atualizar perfil',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
