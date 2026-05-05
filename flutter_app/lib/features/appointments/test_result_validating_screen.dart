import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

// Pantalla de detalle de cita de prueba con timeline de seguimiento
class TestResultValidatingScreen extends StatefulWidget {
  const TestResultValidatingScreen({super.key});
  @override
  State<TestResultValidatingScreen> createState() => _TestResultValidatingScreenState();
}

class _TestResultValidatingScreenState extends State<TestResultValidatingScreen> {
  // Para el MVP, alternamos entre los estados posibles
  // 'validating' = Validando resultado | 'no_show' = No asistió
  String _status = 'validating';

  @override
  Widget build(BuildContext context) {
    final isValidating = _status == 'validating';
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Detalle de la cita', style: AppTheme.heading2().copyWith(fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Folio
          Text('FAV382', style: AppTheme.heading1().copyWith(color: const Color(0xFF13299D), fontSize: 24, letterSpacing: 1.5)),
          const SizedBox(height: 10),

          // Badge de estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isValidating ? const Color(0xFFEFF4FF) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isValidating ? Icons.biotech_rounded : Icons.do_not_disturb_rounded,
                  size: 14, color: isValidating ? const Color(0xFF13299D) : const Color(0xFFDC2626)),
              const SizedBox(width: 6),
              Text(isValidating ? 'Validando resultado' : 'No asistió',
                  style: AppTheme.bodyBold().copyWith(
                      fontSize: 12,
                      color: isValidating ? const Color(0xFF13299D) : const Color(0xFFDC2626))),
            ]),
          ),
          const SizedBox(height: 24),

          // Botón de DEBUG para alternar estado
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.bug_report, size: 16, color: Colors.grey),
              label: Text(isValidating ? 'Simular no asistió' : 'Simular validando',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              onPressed: () => setState(() => _status = isValidating ? 'no_show' : 'validating'),
            ),
          ),

          // Timeline
          _buildTimeline(isValidating),
          const SizedBox(height: 20),

          // Botón Reagendar (solo cuando no asistió)
          if (!isValidating)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/appointments/test'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF13299D),
                  side: const BorderSide(color: Color(0xFF13299D)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                ),
                child: const Text('Reagendar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),

          if (!isValidating) const SizedBox(height: 20),

          // Acordeones de resumen
          _Section(title: 'Tipo de prueba', child: _buildTestSummary()),
          const SizedBox(height: 14),
          _Section(title: 'Datos del paciente', child: _buildPatientSummary()),
          const SizedBox(height: 14),
          _Section(title: 'Detalle de aplicación', child: _buildAppSummary()),
        ]),
      ),
    );
  }

  Widget _buildTimeline(bool isValidating) {
    final steps = [
      _TimelineStep(label: 'Cita agendada', done: true),
      _TimelineStep(label: 'Prueba pagada', done: true),
      _TimelineStep(label: 'Asistencia confirmada', done: true),
      _TimelineStep(
        label: isValidating ? 'Validando resultado' : 'No asistió',
        done: true,
        isCurrent: isValidating,
        isWarning: !isValidating,
        description: isValidating ? 'Estamos validando tu resultado con el equipo médico.' : null,
      ),
    ];

    return Column(children: steps.map((s) {
      final isLast = s == steps.last;
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: s.isWarning ? const Color(0xFFDC2626) : (s.done ? const Color(0xFF13299D) : const Color(0xFFCCCCCC)),
            ),
          ),
          if (!isLast) Container(width: 2, height: 36, color: s.done ? const Color(0xFF13299D) : const Color(0xFFE0E0E0)),
        ]),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.label, style: AppTheme.bodyBold().copyWith(fontSize: 14, color: s.isWarning ? const Color(0xFFDC2626) : AppTheme.textPrimary)),
              if (s.description != null) ...[
                const SizedBox(height: 4),
                Text(s.description!, style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
              ],
            ]),
          ),
        ),
      ]);
    }).toList());
  }

  Widget _buildTestSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.biotech_rounded, color: Color(0xFF2563EB), size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Antígeno COVID-19', style: AppTheme.heading3().copyWith(fontSize: 14)),
          const SizedBox(height: 3),
          Text('Detecta presencia activa del virus SARS-CoV-2.\nA partir de 2 años.',
              style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 11, height: 1.3)),
          const SizedBox(height: 6),
          RichText(text: TextSpan(children: [
            TextSpan(text: '\$1,000.00', style: AppTheme.heading3().copyWith(fontSize: 14)),
            TextSpan(text: 'MXN', style: AppTheme.body().copyWith(fontSize: 10, color: AppTheme.textSecondary)),
          ])),
        ])),
      ]),
    );
  }

  Widget _buildPatientSummary() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.account_circle_outlined, color: AppTheme.textSecondary, size: 22),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Alejandra Valverde Salgado', style: AppTheme.bodyBold().copyWith(fontSize: 14)),
        const SizedBox(height: 3),
        Text('01/Agosto/1990', style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 12)),
      ]),
    ]);
  }

  Widget _buildAppSummary() {
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.storefront_outlined, color: AppTheme.textSecondary, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('México Centro, Xola', style: AppTheme.bodyBold().copyWith(fontSize: 14)),
          const SizedBox(height: 3),
          Text('XOLA 1001 COL: NARVARTE PONIENTE CIUDAD DE MEXICO, CIUDAD DE MEXICO MX',
              style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 11, height: 1.3)),
        ])),
      ]),
      const SizedBox(height: 16),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 22),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Viernes, 20 de noviembre', style: AppTheme.bodyBold().copyWith(fontSize: 14)),
          const SizedBox(height: 3),
          Text('09:45 am', style: AppTheme.body().copyWith(color: AppTheme.textSecondary, fontSize: 12)),
        ]),
      ]),
    ]);
  }
}

class _TimelineStep {
  final String label;
  final bool done;
  final bool isCurrent;
  final bool isWarning;
  final String? description;
  const _TimelineStep({required this.label, required this.done, this.isCurrent = false, this.isWarning = false, this.description});
}

class _Section extends StatefulWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  bool _expanded = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: _expanded ? const BorderRadius.vertical(top: Radius.circular(12)) : BorderRadius.circular(12),
          child: Padding(padding: const EdgeInsets.all(18), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(widget.title, style: AppTheme.heading2().copyWith(fontSize: 15)),
            Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
          ])),
        ),
        if (_expanded) Padding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 18), child: widget.child),
      ]),
    );
  }
}
