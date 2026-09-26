import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import '../../../models/medication_model.dart';

// Tela de formulário para Criar/Editar medicamentos
// Atende tanto a Base Global quanto a edição de prescrição para um Paciente específico
class MedicationFormPage extends StatefulWidget {
  // Se passar um medicamento, entra em modo edição; se for null, cria um novo
  final BaseMedicationModel? medication;

  // Parâmetros opcionais usados quando estamos editando o remédio DE UM PACIENTE
  final String? patientId;
  final String? patientName;
  final String? selectedConcentrationInitial;

  const MedicationFormPage({
    super.key,
    this.medication,
    this.patientId,
    this.patientName,
    this.selectedConcentrationInitial,
  });

  @override
  State<MedicationFormPage> createState() => _MedicationFormPageState();
}

class _MedicationFormPageState extends State<MedicationFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos de texto
  late TextEditingController _nameController;
  late TextEditingController _posologyController;
  late TextEditingController _instructionsController;
  late TextEditingController _newConcentrationController;

  bool _isFreeSus = false;
  List<String> _concentrations = [];
  String? _selectedConcentration;
  bool _isLoading = false;

  // Flag que indica se estamos editando o remédio receitado para um paciente
  bool get _isEditingPatientMedication => widget.patientId != null;

  @override
  void initState() {
    super.initState();
    final med = widget.medication;

    _nameController = TextEditingController(text: med?.name ?? '');
    _posologyController = TextEditingController(text: med?.posology ?? '');
    _instructionsController =
        TextEditingController(text: med?.instructions ?? '');
    _newConcentrationController = TextEditingController();

    _isFreeSus = med?.isFreeSus ?? false;
    _concentrations = List<String>.from(med?.concentrations ?? []);

    _selectedConcentration = widget.selectedConcentrationInitial ??
        (_concentrations.isNotEmpty ? _concentrations.first : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _posologyController.dispose();
    _instructionsController.dispose();
    _newConcentrationController.dispose();
    super.dispose();
  }

  // Adiciona uma nova concentração na lista de tags
  void _addConcentration() {
    final text = _newConcentrationController.text.trim();
    if (text.isNotEmpty && !_concentrations.contains(text)) {
      setState(() {
        _concentrations.add(text);
        _newConcentrationController.clear();
        _selectedConcentration ??= text;
      });
    }
  }

  // Remove uma concentração da lista
  void _removeConcentration(String concentration) {
    setState(() {
      _concentrations.remove(concentration);
      if (_selectedConcentration == concentration) {
        _selectedConcentration =
            _concentrations.isNotEmpty ? _concentrations.first : null;
      }
    });
  }

  // Salva no Supabase (seja na base global ou na tabela do paciente)
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditingPatientMedication && _concentrations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma concentração.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditingPatientMedication) {
        // Atualiza a prescrição do paciente específico
        await supabase.from('patient_medications').update({
          'instructions': _instructionsController.text.trim(),
          'concentration': _selectedConcentration,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', widget.medication!.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Medicamento do paciente atualizado!')),
          );
        }
      } else if (widget.medication != null) {
        // Atualiza na base global
        await supabase.from('medications_base').update({
          'name': _nameController.text.trim(),
          'posology': _posologyController.text.trim(),
          'instructions': _instructionsController.text.trim(),
          'concentrations': _concentrations,
          'is_free_sus': _isFreeSus,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', widget.medication!.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medicamento atualizado na base!')),
          );
        }
      } else {
        // Insere novo na base global
        await supabase.from('medications_base').insert({
          'name': _nameController.text.trim(),
          'posology': _posologyController.text.trim(),
          'instructions': _instructionsController.text.trim(),
          'concentrations': _concentrations,
          'is_free_sus': _isFreeSus,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medicamento adicionado à base!')),
          );
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar medicamento: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Deleta o medicamento
  Future<void> _handleDelete() async {
    final isPatient = _isEditingPatientMedication;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isPatient ? 'Remover do Paciente' : 'Excluir da Base'),
        content: Text(
          isPatient
              ? 'Deseja remover "${widget.medication?.name}" deste paciente?'
              : 'Tem certeza que deseja excluir "${widget.medication?.name}"? Esta ação pode impactar pacientes receitados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD04556)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      if (isPatient) {
        await supabase
            .from('patient_medications')
            .delete()
            .eq('id', widget.medication!.id);
      } else {
        await supabase
            .from('medications_base')
            .delete()
            .eq('id', widget.medication!.id);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          _isEditingPatientMedication
              ? 'Editar para Paciente'
              : (widget.medication != null
                  ? 'Editar Medicamento'
                  : 'Novo Medicamento'),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF353840),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Identificação do Paciente quando em modo de prescrição
                if (_isEditingPatientMedication) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Paciente: ${widget.patientName ?? "N/A"}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87),
                    ),
                  ),
                ],

                // Campo Nome do Remédio
                TextFormField(
                  controller: _nameController,
                  enabled:
                      !_isEditingPatientMedication, // Bloqueado se for modo paciente
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    labelText: 'Nome do Medicamento',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Nome é obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),

                // Campo Posologia
                TextFormField(
                  controller: _posologyController,
                  enabled: !_isEditingPatientMedication,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    labelText: 'Posologia Padrão (Ex: 1 comp a cada 12h)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => !_isEditingPatientMedication &&
                          (val == null || val.trim().isEmpty)
                      ? 'Posologia é obrigatória'
                      : null,
                ),
                const SizedBox(height: 16),

                // Campo Orientações ao Paciente
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    labelText:
                        'Orientações ao Paciente (Ex: Tomar após o almoço)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Orientações são obrigatórias'
                      : null,
                ),
                const SizedBox(height: 16),

                // Seletor de Concentração única (para o Paciente) OU Gerenciador de Lista (para a Base)
                if (_isEditingPatientMedication) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedConcentration,
                    decoration: const InputDecoration(
                      labelText: 'Concentração Prescrita',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _concentrations.map((c) {
                      return DropdownMenuItem(
                          value: c,
                          child: Text(c,
                              style: const TextStyle(color: Colors.black87)));
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedConcentration = val),
                    validator: (val) =>
                        val == null ? 'Selecione uma concentração' : null,
                  ),
                ] else ...[
                  // Gerenciador de tags de concentrações
                  const Text(
                    'Concentrações Disponíveis:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _concentrations.map((conc) {
                      return Chip(
                        backgroundColor: Colors.grey.shade300,
                        label: Text(conc,
                            style: const TextStyle(color: Colors.black87)),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeConcentration(conc),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newConcentrationController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: const InputDecoration(
                            hintText: 'Nova dosagem (ex: 50mg)',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: Color(0xFFD04556), size: 36),
                        onPressed: _addConcentration,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkbox se é gratuito pelo SUS
                  CheckboxListTile(
                    title: const Text('Disponível gratuitamente no SUS',
                        style: TextStyle(color: Colors.black87)),
                    value: _isFreeSus,
                    activeColor: const Color(0xFFD04556),
                    onChanged: (val) =>
                        setState(() => _isFreeSus = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],

                const SizedBox(height: 24),

                // Botão Salvar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD04556),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading ? null : _handleSave,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Salvar Medicamento',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),

                // Botão Excluir (apenas no modo de edição)
                if (widget.medication != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading ? null : _handleDelete,
                    child: Text(
                      _isEditingPatientMedication
                          ? 'Remover do Paciente'
                          : 'Excluir Medicamento',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
