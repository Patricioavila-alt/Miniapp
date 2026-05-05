import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PrescriptionDeliveryNoteScreen
//
// Se muestra cuando el pedido contiene antibióticos y/o psicotrópicos.
// Informa al usuario que debe entregar la receta física al repartidor.
// ─────────────────────────────────────────────────────────────────────────────
class PrescriptionDeliveryNoteScreen extends StatelessWidget {
  // Cada item: { 'name': String, 'isAntibiotic': bool, 'isPsychotropic': bool }
  final List<Map<String, dynamic>> meds;

  const PrescriptionDeliveryNoteScreen({required this.meds, super.key});

  @override
  Widget build(BuildContext context) {
    final hasAntibiotic = meds.any((m) => m['isAntibiotic'] == true);
    final hasPsychotropic = meds.any((m) => m['isPsychotropic'] == true);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Confirmar pedido',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Ícono central ─────────────────────────────────────────────────
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_returned_rounded,
                    size: 48, color: AppTheme.warning),
              ),
            ),
            const SizedBox(height: 20),

            // ── Título y descripción ──────────────────────────────────────────
            const Text(
              'Entrega con receta obligatoria',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _buildDescription(hasAntibiotic, hasPsychotropic),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),

            // ── Lista de medicamentos que requieren receta ────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.shadowSoft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medicamentos que requieren receta',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...meds.asMap().entries.map((e) {
                    final isLast = e.key == meds.length - 1;
                    return Column(
                      children: [
                        _MedRequirementRow(med: e.value),
                        if (!isLast) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: AppTheme.border),
                          const SizedBox(height: 8),
                        ],
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Nota legal / informativa ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.07),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.warning.withOpacity(0.30)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 18, color: AppTheme.warning),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Por disposición de la COFEPRIS, la entrega de estos '
                      'medicamentos requiere la presentación de la receta '
                      'médica original. Sin ella, el repartidor no podrá '
                      'realizar la entrega.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── CTA principal ─────────────────────────────────────────────────
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conectando con farmacia — próximamente.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                elevation: 0,
              ),
              child: const Text(
                'Entendido, ir al carrito',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.secondary,
                side: const BorderSide(color: AppTheme.border),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
              ),
              child: const Text(
                'Revisar medicamentos',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _buildDescription(bool hasAntibiotic, bool hasPsychotropic) {
    if (hasAntibiotic && hasPsychotropic) {
      return 'Tu pedido incluye antibióticos y medicamentos psicotrópicos. '
          'Deberás entregar la receta médica original al repartidor '
          'al momento de recibir tu pedido.';
    }
    if (hasPsychotropic) {
      return 'Tu pedido incluye medicamentos psicotrópicos de control especial. '
          'Deberás entregar la receta médica original al repartidor '
          'al momento de recibir tu pedido.';
    }
    return 'Tu pedido incluye antibióticos que requieren receta médica. '
        'Deberás entregarla al repartidor al momento de recibir tu pedido.';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MedRequirementRow — fila de medicamento con badge de tipo
// ─────────────────────────────────────────────────────────────────────────────
class _MedRequirementRow extends StatelessWidget {
  final Map<String, dynamic> med;
  const _MedRequirementRow({required this.med});

  @override
  Widget build(BuildContext context) {
    final isPsychotropic = med['isPsychotropic'] == true;
    final badgeColor = isPsychotropic ? AppTheme.error : AppTheme.warning;
    final badgeLabel = isPsychotropic ? 'Psicotrópico' : 'Antibiótico';

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.medication_rounded, color: badgeColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                med['name'] as String? ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: badgeColor.withOpacity(0.35)),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.receipt_long_rounded,
            size: 18, color: AppTheme.accent),
      ],
    );
  }
}
