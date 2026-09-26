// Modelo que representa cada alternativa de resposta
class QuestionOption {
  final String value; // O valor que vai pro banco (ex: 'Diariamente', 'Nunca')
  final String label; // O texto legível que aparece na tela pro paciente

  const QuestionOption({
    required this.value,
    required this.label,
  });
}

// Modelo de uma pergunta individual
class QuestionItem {
  final String
      text; // Enunciado (ex: 'Cansaço:' ou '3 - Em relação as tonturas:')
  final String
      stateKey; // A chave de identificação da resposta (ex: 'dorAtiv', 'tonturas')
  final List<QuestionOption> options; // As alternativas disponíveis

  const QuestionItem({
    required this.text,
    required this.stateKey,
    required this.options,
  });
}

// Modelo de um bloco/seção do formulário (pode ser uma pergunta única ou um grupo)
class FormSection {
  final String type; // 'group' ou 'single'
  final String? title; // Título do grupo (quando for do tipo 'group')
  final List<QuestionItem> questions; // Lista de perguntas desse bloco

  const FormSection({
    required this.type,
    this.title,
    required this.questions,
  });
}
