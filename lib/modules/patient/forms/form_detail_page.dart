import 'package:flutter/material.dart';
import '../../../core/constants/form_questions.dart';
import '../../../core/supabase_client.dart';
import '../../../models/form_record_model.dart';

// Tela de detalhes do formulário enviado.
// Serve tanto para o paciente ver o parecer médico quanto para o médico responder.
class FormDetailPage extends StatefulWidget {
  final FormRecordModel formRecord;
  final bool
      isDoctorView; // true: médico respondendo | false: paciente visualizando

  const FormDetailPage({
    super.key,
    required this.formRecord,
    this.isDoctorView = false,
  });

  @override
  State<FormDetailPage> createState() => _FormDetailPageState();
}

class _FormDetailPageState extends State<FormDetailPage> {
  late TextEditingController _doctorResponseController;
  Map<String, dynamic> _answers = {};
  List<String> _imageUrls = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _doctorResponseController = TextEditingController(
      text: widget.formRecord.respostaMedico ?? '',
    );
    _loadFullFormData();
  }

  @override
  void dispose() {
    _doctorResponseController.dispose();
    super.dispose();
  }

  // Carrega respostas salvas e urls de fotos direto do Supabase
  Future<void> _loadFullFormData() async {
    try {
      final response = await supabase
          .from('forms')
          .select('answers, image_urls')
          .eq('id', widget.formRecord.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _answers = Map<String, dynamic>.from(response['answers'] ?? {});
          _imageUrls = List<String>.from(response['image_urls'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Aviso ao carregar respostas completas: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Médico envia parecer clínico para o paciente
  Future<void> _handleSaveDoctorResponse() async {
    final responseText = _doctorResponseController.text.trim();
    if (responseText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, digite uma resposta ao paciente.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await supabase.from('forms').update({
        'resposta_medico': responseText,
        'respondido': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.formRecord.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parecer enviado com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar resposta: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Abre visualização de imagem em tela cheia
  void _openImageModal(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                },
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cor correspondente ao nível de gravidade
  Color _getGravityColor(String gravity) {
    switch (gravity) {
      case 'Grave':
        return Colors.red;
      case 'Moderado':
        return Colors.orange;
      case 'Leve':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.formRecord;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Registro Clínico',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF353840),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD04556)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- CARD DE CLASSIFICAÇÃO DE RISCO ---
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Diagnóstico da Triagem:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87)),
                              Text(
                                  '${form.createdAt.day}/${form.createdAt.month}/${form.createdAt.year}',
                                  style:
                                      const TextStyle(color: Colors.black45)),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Icon(Icons.circle,
                                  color: _getGravityColor(form.diagDorPeito),
                                  size: 14),
                              const SizedBox(width: 8),
                              Text('Dor no Peito: ${form.diagDorPeito}',
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.circle,
                                  color: _getGravityColor(
                                      form.diagInsuficienciaCard),
                                  size: 14),
                              const SizedBox(width: 8),
                              Text(
                                  'Insuficiência Cardíaca: ${form.diagInsuficienciaCard}',
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- ÁREA DE PARECER DO MÉDICO ---
                  if (widget.isDoctorView) ...[
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Resposta ao Paciente:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _doctorResponseController,
                              maxLines: 4,
                              style: const TextStyle(color: Colors.black87),
                              decoration: const InputDecoration(
                                hintText: 'Digite as orientações clínicas...',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFFFAFAFA),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD04556),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed:
                                  _isSaving ? null : _handleSaveDoctorResponse,
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Enviar Parecer',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (form.respostaMedico != null &&
                      form.respostaMedico!.isNotEmpty) ...[
                    // Visão do paciente: resposta do médico em destaque
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                            left: BorderSide(
                                color: Colors.green.shade700, width: 4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Resposta do Médico:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(form.respostaMedico!,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // --- FOTOS DA FERIDA CIRÚRGICA ---
                  if (_imageUrls.isNotEmpty) ...[
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Fotos da Cicatriz:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 110,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _imageUrls.length,
                                itemBuilder: (context, index) {
                                  final img = _imageUrls[index];
                                  return GestureDetector(
                                    onTap: () => _openImageModal(img),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      width: 110,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                            image: NetworkImage(img),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // --- RESPOSTAS DO FORMULÁRIO (READ-ONLY) ---
                  const Text('Respostas Registradas:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 8),

                  ...formQuestionsData.map((section) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (section.title != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(section.title!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ),
                        ],
                        ...section.questions.map((q) {
                          final selectedVal =
                              _answers[q.stateKey]?.toString() ??
                                  'Não respondido';
                          // Pega o label correspondente
                          final optionLabel = q.options
                              .firstWhere((opt) => opt.value == selectedVal,
                                  orElse: () => QuestionOption(
                                      value: selectedVal, label: selectedVal))
                              .label;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: Colors.white,
                            child: ListTile(
                              dense: true,
                              title: Text(q.text,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87)),
                              subtitle: Text(
                                optionLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD04556)),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
