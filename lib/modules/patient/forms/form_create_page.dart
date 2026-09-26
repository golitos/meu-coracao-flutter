import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/form_questions.dart';
import '../../../core/supabase_client.dart';
import '../../../models/question_model.dart';

// Tela onde o paciente responde o questionário clínico e anexa fotos
// Tradução direta e otimizada de Formulario/index.js
class FormCreatePage extends StatefulWidget {
  const FormCreatePage({super.key});

  @override
  State<FormCreatePage> createState() => _FormCreatePageState();
}

class _FormCreatePageState extends State<FormCreatePage> {
  // Guarda as respostas do paciente: chave (stateKey) -> valor selecionado
  final Map<String, String> _answers = {};

  // Lista com as fotos selecionadas localmente
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;

  // 1. Tira foto com a câmera
  Future<void> _takePhoto() async {
    final photo =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (photo != null) {
      setState(() => _selectedImages.add(photo));
    }
  }

  // 2. Escolhe da galeria
  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  // Remove imagem da pré-visualização
  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  // --- MOTOR DO SISTEMA ESPECIALISTA ---

  // Converte texto da resposta em pontuação clínica (0 a 3)
  int _getScore(String? answer) {
    if (answer == null) return 0;
    if (answer == 'Muito' ||
        answer == 'Diariamente' ||
        answer == 'SeteaOito' ||
        answer == 'NoveaDez') {
      return 3;
    }
    if (answer == 'Moderadamente' ||
        answer == 'QuatroaSeis' ||
        answer == 'CincoaSete') {
      return 2;
    }
    if (answer == 'Pouco' || answer == 'UmaTres' || answer == 'TresaCinco') {
      return 1;
    }
    return 0; // Nenhum / Nunca
  }

  // Calcula a gravidade da Insuficiência Cardíaca
  String _calculateHeartFailureGravity() {
    int score = 0;
    const keys = [
      'dorAtiv',
      'dorAtivBC',
      'dorAtivFA',
      'cansacoR',
      'batimentoR',
      'faltaArR',
      'tonturas',
      'desmaio',
      'pressaoAlta',
      'suadoresFrios',
      'branco',
      'vomitar',
      'inchaco'
    ];

    for (var key in keys) {
      score += _getScore(_answers[key]);
    }

    if (score <= 10) return 'Tranquilo';
    if (score <= 20) return 'Leve';
    if (score <= 30) return 'Moderado';
    return 'Grave';
  }

  // Calcula a gravidade da Dor no Peito
  String _calculateChestPainGravity() {
    int score = 0;
    const keys = [
      'dorAtivDP',
      'dorPeitoR',
      'dorPeito',
      'outroL',
      'nivelDor',
      'dorAtivP',
      'dorPeito100',
      'qualquerAtiv'
    ];

    for (var key in keys) {
      score += _getScore(_answers[key]);
    }

    if (score <= 5) return 'Tranquilo';
    if (score <= 15) return 'Leve';
    if (score <= 23) return 'Moderado';
    return 'Grave';
  }

  // Validação: Garante que todas as 22 perguntas foram respondidas
  bool _validateAllAnswered() {
    for (var section in formQuestionsData) {
      for (var q in section.questions) {
        if (!_answers.containsKey(q.stateKey) ||
            _answers[q.stateKey]!.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  // Salva respostas e faz upload das imagens para o Supabase
  Future<void> _handleSave() async {
    if (!_validateAllAnswered()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Atenção'),
          content: const Text(
              'É necessário responder todas as perguntas do formulário.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      final diagInsuficiencia = _calculateHeartFailureGravity();
      final diagDor = _calculateChestPainGravity();

      // 1. Salva o registro clínico na tabela 'forms'
      final formInsert = await supabase
          .from('forms')
          .insert({
            'user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
            'diag_dor_peito': diagDor,
            'diag_insuficiencia_card': diagInsuficiencia,
            'has_images': _selectedImages.isNotEmpty,
            'answers':
                _answers, // Salva o mapa completo das 22 respostas em formato JSON
            'respondido': false,
          })
          .select()
          .single();

      final formId = formInsert['id'].toString();

      // 2. Faz upload das imagens (se houver) no Supabase Storage
      final List<String> imageUrls = [];
      for (var i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];
        final bytes = await File(image.path).readAsBytes();
        final path = 'forms/$formId/wound_$i.jpg';

        await supabase.storage.from('wound_photos').uploadBinary(path, bytes);
        final url = supabase.storage.from('wound_photos').getPublicUrl(path);
        imageUrls.add(url);
      }

      if (imageUrls.isNotEmpty) {
        await supabase
            .from('forms')
            .update({'image_urls': imageUrls}).eq('id', formId);
      }

      // 3. Exibe o parecer do Sistema Especialista para o paciente
      if (mounted) {
        _showResultFeedback(diagDor, diagInsuficiencia);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar formulário: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Modal final com orientações e alerta de gravidade do especialista
  void _showResultFeedback(String diagDor, String diagInsuficiencia) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Avaliação Concluída',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dor no Peito: $diagDor',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: diagDor == 'Grave' ? Colors.red : Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Insuficiência Cardíaca: $diagInsuficiencia',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: diagInsuficiencia == 'Grave'
                        ? Colors.red
                        : Colors.black87),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6)),
                child: const Text(
                  'Durante o pós-operatório cardíaco, tome as medicações prescritas, mantenha repouso adequado e procure assistência imediata se os sintomas aumentarem.',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD04556)),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true); // Volta para a Home atualizada
            },
            child:
                const Text('Finalizar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Novo Formulário',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF353840),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Renderização dinâmica de todas as seções e perguntas
            ...formQuestionsData.map((section) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section.title != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        section.title!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87),
                      ),
                    ),
                  ],
                  ...section.questions.map((question) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.grey.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.text,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            // Lista de alternativas (RadioListTile)
                            ...question.options.map((opt) {
                              return RadioListTile<String>(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                activeColor: const Color(0xFFD04556),
                                title: Text(opt.label,
                                    style:
                                        const TextStyle(color: Colors.black87)),
                                value: opt.value,
                                groupValue: _answers[question.stateKey],
                                onChanged: (val) {
                                  setState(() {
                                    if (val != null)
                                      _answers[question.stateKey] = val;
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),

            const SizedBox(height: 16),

            // --- SEÇÃO DE FOTOS DA CICATRIZ ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fotos da Cicatriz Pós-operatória (Opcional)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD04556)),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeria'),
                        onPressed: _pickImages,
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD04556)),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Câmera'),
                        onPressed: _takePhoto,
                      ),
                    ],
                  ),
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(
                                        File(_selectedImages[index].path)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botão Salvar Formulário
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD04556),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Salvar Formulário',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
