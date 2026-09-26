// Modelo que representa um medicamento da base global
class BaseMedicationModel {
  final String id;
  final String name;
  final String? posology; // Posologia padrão/referência médica
  final String? instructions; // Orientações de cuidados e higiene
  final List<String> concentrations; // Ex: ['25mg', '50mg', '100mg']
  final bool isFreeSus; // Se é fornecido gratuitamente pelo SUS

  BaseMedicationModel({
    required this.id,
    required this.name,
    this.posology,
    this.instructions,
    this.concentrations = const [],
    this.isFreeSus = false,
  });

  // Converte o retorno do Supabase (JSON) para o objeto Dart
  factory BaseMedicationModel.fromJson(Map<String, dynamic> json) {
    return BaseMedicationModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      posology: json['posology'],
      instructions: json['instructions'],
      // Converte lista dinâmica para List<String>
      concentrations: (json['concentrations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFreeSus: json['is_free_sus'] ?? json['isFree'] ?? false,
    );
  }

  // Converte o objeto para JSON para salvar no Supabase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'posology': posology,
      'instructions': instructions,
      'concentrations': concentrations,
      'is_free_sus': isFreeSus,
    };
  }
}

// Representa um remédio específico associado a um paciente
class PatientMedicationModel {
  final String id;
  final String patientId;
  final String name;
  final String? concentration; // Ex: 50mg
  final String? frequency; // Posologia (Ex: 1 comp a cada 12h)
  final String? instructions; // Orientações de cuidados
  final bool isFree;
  final bool purchased; // Se o paciente já comprou/retirou
  final DateTime createdAt;

  PatientMedicationModel({
    required this.id,
    required this.patientId,
    required this.name,
    this.concentration,
    this.frequency,
    this.instructions,
    this.isFree = false,
    this.purchased = false,
    required this.createdAt,
  });

  factory PatientMedicationModel.fromJson(Map<String, dynamic> json) {
    return PatientMedicationModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id'] ?? json['patientId'] ?? '',
      name: json['name'] ?? '',
      concentration: json['concentration'],
      frequency: json['frequency'] ?? json['posology'],
      instructions: json['instructions'],
      isFree: json['is_free'] ?? (json['isFree'] == 1),
      purchased: json['purchased'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  // Verifica se o remédio foi adicionado há menos de 7 dias
  bool get isNew => DateTime.now().difference(createdAt).inDays < 7;
}
