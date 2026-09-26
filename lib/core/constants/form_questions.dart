import '../../models/question_model.dart';

// Lista completa de perguntas clínicas de pós-operatório cardíaco
// Traduzido diretamente do antigo formQuestions.js
const List<FormSection> formQuestionsData = [
  // --- GRUPO 1: ATIVIDADE FÍSICA LEVE ---
  FormSection(
    type: 'group',
    title:
        '1 - Quando o (a) senhor (a) realiza uma atividade física leve (dar uma caminhada, fazer uma atividade em casa ou ir ao supermercado), como se sente em relação:',
    questions: [
      QuestionItem(
        text: 'Cansaço:',
        stateKey: 'dorAtiv',
        options: [
          QuestionOption(value: 'Muito', label: 'Muito cansado'),
          QuestionOption(
              value: 'Moderadamente', label: 'Moderadamente cansado'),
          QuestionOption(value: 'Pouco', label: 'Pouco cansado'),
          QuestionOption(value: 'Nenhum', label: 'Nenhum cansaço'),
        ],
      ),
      QuestionItem(
        text: 'Batimento cardíaco:',
        stateKey: 'dorAtivBC',
        options: [
          QuestionOption(value: 'Muito', label: 'Muito aumentado'),
          QuestionOption(
              value: 'Moderadamente', label: 'Moderadamente aumentado'),
          QuestionOption(value: 'Pouco', label: 'Pouco aumentado'),
          QuestionOption(value: 'Nenhum', label: 'Nenhuma alteração'),
        ],
      ),
      QuestionItem(
        text: 'Falta de ar:',
        stateKey: 'dorAtivFA',
        options: [
          QuestionOption(value: 'Muito', label: 'Muita falta de ar'),
          QuestionOption(
              value: 'Moderadamente', label: 'Moderadamente com falta de ar'),
          QuestionOption(value: 'Pouco', label: 'Pouca falta de ar'),
          QuestionOption(value: 'Nenhum', label: 'Nenhuma falta de ar'),
        ],
      ),
      QuestionItem(
        text: 'Dor no peito:',
        stateKey: 'dorAtivDP',
        options: [
          QuestionOption(value: 'Muito', label: 'Muita dor'),
          QuestionOption(value: 'Moderadamente', label: 'Dor moderada'),
          QuestionOption(value: 'Pouco', label: 'Pouca dor'),
          QuestionOption(value: 'Nenhum', label: 'Nenhuma dor'),
        ],
      ),
    ],
  ),

  // --- GRUPO 2: EM REPOUSO ---
  FormSection(
    type: 'group',
    title: '2 - Quando está em repouso (sem esforço) apresenta:',
    questions: [
      QuestionItem(
        text: 'Cansaço:',
        stateKey: 'cansacoR',
        options: [
          QuestionOption(value: 'Muito', label: 'Muito cansado'),
          QuestionOption(
              value: 'Moderadamente', label: 'Moderadamente cansado'),
          QuestionOption(value: 'Pouco', label: 'Pouco cansado'),
          QuestionOption(value: 'Nenhum', label: 'Nenhum cansaço'),
        ],
      ),
      QuestionItem(
        text: 'Batimento cardíaco:',
        stateKey: 'batimentoR',
        options: [
          QuestionOption(value: 'Muito', label: 'Muito aumentado'),
          QuestionOption(
              value: 'Moderadamente', label: 'Moderadamente aumentado'),
          QuestionOption(value: 'Pouco', label: 'Pouco aumentado'),
          QuestionOption(value: 'Nenhum', label: 'Nenhuma alteração'),
        ],
      ),
      QuestionItem(
        text: 'Falta de ar:',
        stateKey: 'faltaArR',
        options: [
          QuestionOption(value: 'Muito', label: 'Muita falta de ar'),
          QuestionOption(
              value: 'Moderadamente', label: 'Moderadamente com falta de ar'),
          QuestionOption(value: 'Pouco', label: 'Pouca falta de ar'),
          QuestionOption(value: 'Nenhum', label: 'Nenhuma falta de ar'),
        ],
      ),
      QuestionItem(
        text: 'Dor no peito:',
        stateKey: 'dorPeitoR',
        options: [
          QuestionOption(value: 'Muito', label: 'Muita dor'),
          QuestionOption(value: 'Moderadamente', label: 'Dor moderada'),
          QuestionOption(value: 'Pouco', label: 'Pouca dor'),
          QuestionOption(value: 'Nenhum', label: 'Nenhuma dor'),
        ],
      ),
    ],
  ),

  // --- PERGUNTAS INDIVIDUAIS (3 a 16) ---
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text: '3 - Em relação as tonturas:',
        stateKey: 'tonturas',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text: '4 - Em relação ao desmaio:',
        stateKey: 'desmaio',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text: '5 - Em relação a dor no peito:',
        stateKey: 'dorPeito',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text: '6 - Em relação a pressão alta:',
        stateKey: 'pressaoAlta',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text: '7 - Apresenta suadores frios:',
        stateKey: 'suadoresFrios',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text: '8 - Apresenta pele do rosto e os lábios da boca brancos:',
        stateKey: 'branco',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text: '9 - Apresenta vontade de vomitar:',
        stateKey: 'vomitar',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text: '10 - Apresenta inchaço nas pernas, tornozelos e pés:',
        stateKey: 'inchaco',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text:
            '11 - A dor no peito também aparece em algum outro lugar no corpo como: braço esquerdo, mandíbula, estômago, costas ou pescoço:',
        stateKey: 'outroL',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text:
            '12 - Em uma escala de 1 a 10, sendo 10 a pior dor, como você classifica a sua dor?',
        stateKey: 'nivelDor',
        options: [
          QuestionOption(value: 'UmaTres', label: '1 até 3'),
          QuestionOption(value: 'TresaCinco', label: '3 até 5'),
          QuestionOption(value: 'CincoaSete', label: '5 até 7'),
          QuestionOption(value: 'SeteaOito', label: '7 até 8'),
          QuestionOption(value: 'NoveaDez', label: '9 até 10'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text:
            '13 - Você tem dor no peito após atividades intensas prolongadas:',
        stateKey: 'dorAtivP',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text:
            '14 - Você tem dor no peito após caminhar 200 m ou subir dois lances de escada:',
        stateKey: 'dorPeito200',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text:
            '15 - Você tem dor no peito após caminhar 100 m ou subir um lance de escada:',
        stateKey: 'dorPeito100',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
  FormSection(
    type: 'single',
    questions: [
      QuestionItem(
        text: '16 - Você tem dor no peito após realizar qualquer atividade:',
        stateKey: 'qualquerAtiv',
        options: [
          QuestionOption(value: 'Diariamente', label: 'Diariamente'),
          QuestionOption(value: 'QuatroaSeis', label: '4 a 6 vezes na semana'),
          QuestionOption(value: 'UmaTres', label: '1 a 3 vezes na semana'),
          QuestionOption(value: 'Nunca', label: 'Nunca apresento'),
        ],
      ),
    ],
  ),
];
