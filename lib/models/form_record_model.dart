// Modelo que representa um formulário de acompanhamento enviado pelo paciente
class FormRecordModel {
  final String id;
  final String userId;
  final DateTime createdAt;
  final String diagDorPeito; // Tranquilo, Leve, Moderado, Grave
  final String diagInsuficienciaCard;
  final bool respondido;
  final String? respostaMedico;
  final String? photoUrl; // Foto da cicatriz / ferida

  FormRecordModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.diagDorPeito = 'Tranquilo',
    this.diagInsuficienciaCard = 'Tranquilo',
    this.respondido = false,
    this.respostaMedico,
    this.photoUrl,
  });

  // Converte os dados do Supabase
  factory FormRecordModel.fromJson(Map<String, dynamic> json) {
    return FormRecordModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? json['user'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['created'] != null
              ? DateTime.parse(json['created'])
              : DateTime.now()),
      diagDorPeito:
          json['diag_dor_peito'] ?? json['diagDorPeito'] ?? 'Tranquilo',
      diagInsuficienciaCard: json['diag_insuficiencia_card'] ??
          json['diagInsuficienciaCard'] ??
          'Tranquilo',
      respondido: json['respondido'] ?? false,
      respostaMedico: json['resposta_medico'] ?? json['resposta'],
      photoUrl: json['photo_url'] ?? json['photoUrl'],
    );
  }

  // Define a gravidade máxima calculada pelo formulário
  String get gravityLevel {
    if (diagDorPeito == 'Grave' || diagInsuficienciaCard == 'Grave') {
      return 'Grave';
    }
    if (diagDorPeito == 'Moderado' || diagInsuficienciaCard == 'Moderado') {
      return 'Moderado';
    }
    if (diagDorPeito == 'Leve' || diagInsuficienciaCard == 'Leve') {
      return 'Leve';
    }
    return 'Tranquilo';
  }
}
