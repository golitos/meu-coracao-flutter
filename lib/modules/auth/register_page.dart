import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/supabase_client.dart';

// Ecrã de Registo (Criação de Conta)
// Tradução direta de Cadastrar.js (Lida com Pacientes e Médicos)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _accountType = 'P'; // 'P' para Paciente, 'M' para Médico
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Controladores Globais (Usados em ambas as contas)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controladores Exclusivos: Paciente
  final _motherNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  String? _selectedSex;
  String? _selectedDoctorId;

  // Controladores Exclusivos: Médico
  final _crmController = TextEditingController();
  String? _selectedState;

  // Listas Dinâmicas
  List<Map<String, dynamic>> _doctorsList = [];
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
    _fetchDoctors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _motherNameController.dispose();
    _phoneController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _crmController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('id, name')
          .eq('is_doctor', true);

      setState(() {
        _doctorsList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Aviso ao carregar médicos: $e');
    }
  }

  void _showErrorModal(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atenção',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD04556)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (_accountType == 'M') {
      // Registo de Médico
      if (name.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          _crmController.text.isEmpty ||
          _selectedState == null) {
        _showErrorModal('É necessário informar todos os campos.');
        return;
      }
      if (password.length < 7) {
        _showErrorModal('A senha deve conter no mínimo 7 caracteres.');
        return;
      }
    } else {
      // Registo de Paciente
      if (name.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          _phoneController.text.isEmpty ||
          _motherNameController.text.isEmpty ||
          _dayController.text.isEmpty ||
          _monthController.text.isEmpty ||
          _yearController.text.isEmpty ||
          _selectedSex == null ||
          _selectedDoctorId == null) {
        _showErrorModal('É necessário informar todos os campos.');
        return;
      }
      if (password.length < 7) {
        _showErrorModal('A senha deve conter no mínimo 7 caracteres.');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();

      if (_accountType == 'M') {
        await authService.signUpMedico(
          email: email,
          password: password,
          name: name,
          crm: _crmController.text.trim(),
          state: _selectedState!,
        );
      } else {
        await authService.signUpPaciente(
          email: email,
          password: password,
          name: name,
          phone: _phoneController.text.trim(),
          motherName: _motherNameController.text.trim(),
          sex: _selectedSex!,
          doctorId: _selectedDoctorId!,
          birthDay: int.parse(_dayController.text.trim()),
          birthMonth: int.parse(_monthController.text.trim()),
          birthYear: int.parse(_yearController.text.trim()),
        );
      }

      // O AuthService atualizará o estado de autenticação e a view mudará
      if (mounted)
        Navigator.pop(
            context); // Volta ao ecrã inicial após o registo (a AuthWrapper assume)
    } catch (e) {
      _showErrorModal('Falha ao registar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA0A4A5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                  children: [
                    TextSpan(
                        text: 'meu', style: TextStyle(color: Colors.white)),
                    TextSpan(
                        text: 'Coração',
                        style: TextStyle(color: Color(0xFFFF1933))),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Seleção de Tipo de Conta
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: 'P',
                    groupValue: _accountType,
                    activeColor: Colors.white,
                    fillColor: MaterialStateProperty.all(Colors.white),
                    onChanged: (val) => setState(() => _accountType = val!),
                  ),
                  const Text('Sou paciente',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 10),
                  Radio<String>(
                    value: 'M',
                    groupValue: _accountType,
                    activeColor: Colors.white,
                    fillColor: MaterialStateProperty.all(Colors.white),
                    onChanged: (val) => setState(() => _accountType = val!),
                  ),
                  const Text('Sou profissional',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),

              // --- FORMULÁRIO DO PACIENTE ---
              if (_accountType == 'P') ...[
                _buildTextField(_nameController, 'Nome Completo'),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Data de Nascimento',
                        style: TextStyle(color: Colors.white, fontSize: 16))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(_dayController, 'Dia',
                            type: TextInputType.number)),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('/',
                            style:
                                TextStyle(color: Colors.white, fontSize: 24))),
                    Expanded(
                        child: _buildTextField(_monthController, 'Mês',
                            type: TextInputType.number)),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('/',
                            style:
                                TextStyle(color: Colors.white, fontSize: 24))),
                    Expanded(
                        flex: 2,
                        child: _buildTextField(_yearController, 'Ano',
                            type: TextInputType.number)),
                  ],
                ),
                _buildTextField(_motherNameController, 'Nome da Mãe'),
                _buildTextField(_phoneController, 'Telefone',
                    type: TextInputType.phone),
                DropdownButtonFormField<String>(
                  value: _selectedSex,
                  dropdownColor: const Color(0xFF353840),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Sexo',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2))),
                  items: const [
                    DropdownMenuItem(
                        value: 'M',
                        child: Text('Masculino',
                            style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(
                        value: 'F',
                        child: Text('Feminino',
                            style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (val) => setState(() => _selectedSex = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedDoctorId,
                  dropdownColor: const Color(0xFF353840),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Médico Responsável',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2))),
                  items: _doctorsList
                      .map((doc) => DropdownMenuItem<String>(
                          value: doc['id'].toString(),
                          child: Text(doc['name'],
                              style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedDoctorId = val),
                ),
                const SizedBox(height: 12),
              ]

              // --- FORMULÁRIO DO MÉDICO ---
              else ...[
                _buildTextField(_nameController, 'Nome Completo'),
                _buildTextField(_crmController, 'CRM'),
                DropdownButtonFormField<String>(
                  value: _selectedState,
                  dropdownColor: const Color(0xFF353840),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Estado de atuação',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2))),
                  items: _stateList
                      .map((st) => DropdownMenuItem<String>(
                          value: st['value'],
                          child: Text(st['label']!,
                              style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedState = val),
                ),
                const SizedBox(height: 12),
              ],

              // Credenciais Comuns
              _buildTextField(_emailController, 'Email',
                  type: TextInputType.emailAddress),
              _buildTextField(_passwordController, 'Senha', isPassword: true),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD04556),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Cadastrar',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Já possuo uma conta',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
