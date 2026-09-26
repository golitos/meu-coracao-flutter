import 'package:flutter/material.dart';
import '../../../models/form_record_model.dart';
import '../../patient/forms/form_detail_page.dart';

// Card reutilizável que representa um formulário de paciente visto pelo médico.
// Substitui o componente ListFormMedico/index.js.
class DoctorFormCard extends StatelessWidget {
  final FormRecordModel form;
  final String patientName;
  final VoidCallback? onRefresh;

  const DoctorFormCard({
    super.key,
    required this.form,
    required this.patientName,
    this.onRefresh,
  });

  // Cor correspondente à gravidade calculada
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
    final gravityColor = _getGravityColor(form.gravityLevel);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          // Abre a tela de detalhes no modo médico para responder o formulário
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormDetailPage(
                formRecord: form,
                isDoctorView: true,
              ),
            ),
          );
          if (updated == true && onRefresh != null) {
            onRefresh!();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome do paciente e data do envio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    patientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${form.createdAt.day.toString().padLeft(2, '0')}/${form.createdAt.month.toString().padLeft(2, '0')}/${form.createdAt.year}',
                    style: const TextStyle(color: Colors.black45, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Indicador de risco e status de resposta
              Row(
                children: [
                  Icon(Icons.circle, size: 12, color: gravityColor),
                  const SizedBox(width: 6),
                  Text(
                    'Risco: ${form.gravityLevel}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gravityColor,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: form.respondido
                          ? Colors.green.withOpacity(0.12)
                          : const Color(0xFFD04556).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          form.respondido
                              ? Icons.check_circle
                              : Icons.access_time,
                          size: 14,
                          color: form.respondido
                              ? Colors.green
                              : const Color(0xFFD04556),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          form.respondido ? 'Respondido' : 'Pendente',
                          style: TextStyle(
                            color: form.respondido
                                ? Colors.green
                                : const Color(0xFFD04556),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
