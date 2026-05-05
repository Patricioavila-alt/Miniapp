import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ScheduleTypeScreen — ¿Qué te gustaría agendar?
// ─────────────────────────────────────────────────────────────────────────────
class ScheduleTypeScreen extends StatelessWidget {
  const ScheduleTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Agendar cita',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              '¿Qué te gustaría agendar?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona el tipo de servicio que necesitas.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),

            // Tarjeta: Orientación Médica
            _ScheduleTypeCard(
              icon: Icons.medical_services_rounded,
              iconColor: const Color(0xFFE05C3D),
              iconBg: const Color(0xFFFFF0EC),
              title: 'Orientación Médica',
              subtitle: 'Videoconsulta o presencial con nuestros especialistas.',
              onTap: () => context.push(AppRoutes.consultSymptoms),
            ),
            const SizedBox(height: 16),

            // Tarjeta: Vacunas
            _ScheduleTypeCard(
              icon: Icons.vaccines_rounded,
              iconColor: const Color(0xFF3B82F6),
              iconBg: const Color(0xFFEFF6FF),
              title: 'Vacunas',
              subtitle: 'Programa tu esquema de vacunación en sucursal.',
              onTap: () => context.push(AppRoutes.vaccineType),
            ),
            const SizedBox(height: 16),

            // Tarjeta: Estudios diagnósticos
            _ScheduleTypeCard(
              icon: Icons.biotech_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFF5F3FF),
              title: 'Estudios diagnósticos',
              subtitle: 'Antígenos, influenza, COVID-19 y más en sucursal.',
              onTap: () => context.push(AppRoutes.testType),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ScheduleTypeCard — Tarjeta de tipo de cita
// ─────────────────────────────────────────────────────────────────────────────
class _ScheduleTypeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ScheduleTypeCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícono
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.border, size: 22),
          ],
        ),
      ),
    );
  }
}
