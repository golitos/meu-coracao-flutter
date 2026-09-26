import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';

// Tela de edição completa dos dados cadastrais e clínicos do paciente
// Tradução direta de AtualizarPerfilPacienteP.js
class PatientEditProfilePage extends StatefulWidget {
  const PatientEditProfilePage({super.key});

  @override
  State<PatientEditProfilePage> createState() => _PatientEditProfilePageState();
}

class _PatientEditProfilePageState extends State<PatientEditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _nameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _otherSurgeryController = TextEditingController();

  // Seletores e Comorbidades
  String? _selectedSex;
  String? _selectedDoctorId;
  String? _selectedSurgery;
  String _diabetes = 'Nao';
  String _hipertensao = 'Nao';

  List<Map<String, dynamic>> _doctorList = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // Lista de tipos de cirurgias cardíacas
  final List<Map<String, String>> _surgeryTypes = const [
    {'value': 'RM', 'label': 'Revascularização do miocárdio'},
    {'value': 'TVA', 'label': 'Troca valvar aórtica'},
    {'value': 'TVM', 'label': 'Troca valvar mitral'},
    {'value': 'RA', 'label': 'Reconstrução de aorta'},
    {'value': 'IM', 'label': 'Implante de marcapasso'},
    {'value': 'CE', 'label': 'Cirurgia estrutural (comunicação interatrial)'},
    {'value': 'O', 'label': 'Outra'},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _motherNameController.dispose();
    _phoneController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _otherSurgeryController.dispose();
    super.dispose();
  }

  // Carrega médicos cadastrados e dados do perfil atual
  Future<void> _loadInitialData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Busca lista de médicos disponíveis
      final doctorsResponse = await supabase
          .from('profiles')
          .select('id, name')
          .eq('is_doctor', true);

      _doctorList = List<Map<String, dynamic>>.from(doctorsResponse);

      // 2. Busca perfil atual do paciente
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        _nameController.text = profile['name'] ?? '';
        _motherNameController.text = profile['mother_name'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _dayController.text = profile['birth_day']?.toString() ?? '';
        _monthController.text = profile['birth_month']?.toString() ?? '';
        _yearController.text = profile['birth_year']?.toString() ?? '';
        _otherSurgeryController.text = profile['other_surgery'] ?? '';

        _selectedSex = profile['sex'];
        _selectedDoctorId = profile['doctor_id'];
        _selectedSurgery = profile['surgery_type'];
        _diabetes = profile['diabetes'] == true ? 'Sim' : 'Nao';
        _hipertensao = profile['hypertension'] == true ? 'Sim' : 'Nao';
      }
    } catch (e) {
      debugPrint('Aviso ao carregar dados do perfil: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Salva os dados atualizados no Supabase
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSurgery == null || _selectedSurgery!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecione o tipo de cirurgia.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final userId = supabase.auth.currentUser?.id;

    try {
      await supabase.from('profiles').update({
        'name': _nameController.text.trim(),
        'mother_name': _motherNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'birth_day': int.tryParse(_dayController.text.trim()),
        'birth_month': int.tryParse(_monthController.text.trim()),
        'birth_year': int.tryParse(_yearController.text.trim()),
        'sex': _selectedSex,
        'doctor_id': _selectedDoctorId,
        'surgery_type': _selectedSurgery,
        'other_surgery': _selectedSurgery == 'O'
            ? _otherSurgeryController.text.trim()
            : null,
        'diabetes': _diabetes == 'Sim',
        'hypertension': _hipertensao == 'Sim',
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
        title: const Text('Atualizar Perfil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF353840),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD04556)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nome Completo
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Nome é obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Data de Nascimento (Dia / Mês / Ano)
                    const Text('Data de Nascimento:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dayController,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(
                                hintText: 'Dia',
                                border: OutlineInputBorder(),
                                counterText: ''),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('/',
                              style: TextStyle(
                                  fontSize: 22, color: Colors.black54)),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _monthController,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(
                                hintText: 'Mês',
                                border: OutlineInputBorder(),
                                counterText: ''),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('/',
                              style: TextStyle(
                                  fontSize: 22, color: Colors.black54)),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _yearController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(
                                hintText: 'Ano',
                                border: OutlineInputBorder(),
                                counterText: ''),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nome da Mãe
                    TextFormField(
                      controller: _motherNameController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                          labelText: 'Nome da Mãe',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    // Telefone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                          labelText: 'Telefone', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    // Sexo
                    DropdownButtonFormField<String>(
                      value: _selectedSex,
                      decoration: const InputDecoration(
                          labelText: 'Sexo', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(
                            value: 'M',
                            child: Text('Masculino',
                                style: TextStyle(color: Colors.black87))),
                        DropdownMenuItem(
                            value: 'F',
                            child: Text('Feminino',
                                style: TextStyle(color: Colors.black87))),
                      ],
                      onChanged: (val) => setState(() => _selectedSex = val),
                    ),
                    const SizedBox(height: 16),

                    // Selecionar Médico Responsável
                    DropdownButtonFormField<String>(
                      value: _selectedDoctorId,
                      decoration: const InputDecoration(
                          labelText: 'Médico Responsável',
                          border: OutlineInputBorder()),
                      items: _doctorList.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc['id'].toString(),
                          child: Text(doc['name'] ?? 'Sem Nome',
                              style: const TextStyle(color: Colors.black87)),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedDoctorId = val),
                    ),
                    const SizedBox(height: 16),

                    // Tipo de Cirurgia
                    DropdownButtonFormField<String>(
                      value: _selectedSurgery,
                      decoration: const InputDecoration(
                          labelText: 'Cirurgia Realizada',
                          border: OutlineInputBorder()),
                      items: _surgeryTypes.map((s) {
                        return DropdownMenuItem<String>(
                          value: s['value']!,
                          child: Text(s['label']!,
                              style: const TextStyle(color: Colors.black87)),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedSurgery = val),
                    ),
                    const SizedBox(height: 16),

                    // Campo Condicional: Outra Cirurgia
                    if (_selectedSurgery == 'O') ...[
                      TextFormField(
                        controller: _otherSurgeryController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: const InputDecoration(
                            labelText: 'Especifique o nome da cirurgia',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Comorbidades: Diabetes
                    const Text('Possui diabetes?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Sim',
                          groupValue: _diabetes,
                          activeColor: const Color(0xFFD04556),
                          onChanged: (v) => setState(() => _diabetes = v!),
                        ),
                        const Text('Sim',
                            style: TextStyle(color: Colors.black87)),
                        const SizedBox(width: 24),
                        Radio<String>(
                          value: 'Nao',
                          groupValue: _diabetes,
                          activeColor: const Color(0xFFD04556),
                          onChanged: (v) => setState(() => _diabetes = v!),
                        ),
                        const Text('Não',
                            style: TextStyle(color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Comorbidades: Hipertensão
                    const Text('Possui hipertensão?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Sim',
                          groupValue: _hipertensao,
                          activeColor: const Color(0xFFD04556),
                          onChanged: (v) => setState(() => _hipertensao = v!),
                        ),
                        const Text('Sim',
                            style: TextStyle(color: Colors.black87)),
                        const SizedBox(width: 24),
                        Radio<String>(
                          value: 'Nao',
                          groupValue: _hipertensao,
                          activeColor: const Color(0xFFD04556),
                          onChanged: (v) => setState(() => _hipertensao = v!),
                        ),
                        const Text('Não',
                            style: TextStyle(color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Botão Atualizar Perfil
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD04556),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Atualizar Perfil',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
