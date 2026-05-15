import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ScheduleTypeScreen — Grid 2×4 de servicios de cita
// Layout: 4 filas × 2 columnas con colores del proyecto
// ─────────────────────────────────────────────────────────────────────────────
class ScheduleTypeScreen extends StatelessWidget {
  const ScheduleTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Agendar cita',
          style: AppTheme.heading2().copyWith(fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Fila 1: Vacuna | Prueba ───────────────────────────────────────
          Expanded(
            child: _GridRow(
              left: _ServiceTile(
                title: 'Vacuna',
                subtitle: 'Agenda tu cita',
                tag: 'Sucursal',
                icon: Icons.vaccines_rounded,
                onTap: () => context.push(AppRoutes.vaccineType),
              ),
              right: _ServiceTile(
                title: 'Prueba',
                subtitle: 'Agenda tu cita',
                tag: 'Sucursal',
                icon: Icons.biotech_rounded,
                onTap: () => context.push(AppRoutes.testType),
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),

          // ── Fila 2: Médico General | Pediatra ────────────────────────────
          Expanded(
            child: _GridRow(
              left: _ServiceTile(
                title: 'Médico General',
                subtitle: 'Consulta ahora',
                tag: 'On demand · Tercero',
                useDoctorIcon: true,
                onTap: () => context.push(AppRoutes.consultSymptoms),
              ),
              right: _ServiceTile(
                title: 'Pediatra',
                subtitle: 'Consulta ahora',
                tag: 'On demand · Tercero',
                useDoctorIcon: true,
                onTap: () => context.push(AppRoutes.consultSymptoms),
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),

          // ── Fila 3: Dermatología | Control Diabetes ───────────────────────
          Expanded(
            child: _GridRow(
              left: _ServiceTile(
                title: 'Dermatología',
                subtitle: 'Consulta ahora',
                tag: 'On demand · Tercero',
                useDoctorIcon: true,
                onTap: () => context.push(AppRoutes.consultSymptoms),
              ),
              right: _ServiceTile(
                title: 'Control Diabetes',
                subtitle: 'Consulta ahora',
                tag: 'On demand · Tercero',
                useDoctorIcon: true,
                onTap: () => context.push(AppRoutes.consultSymptoms),
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),

          // ── Fila 4: Salud Mental | Red Médica ────────────────────────────
          Expanded(
            child: _GridRow(
              left: _ServiceTile(
                title: 'Salud Mental',
                subtitle: 'Agenda tu cita',
                tag: 'Cita programada · Tercero',
                useDoctorIcon: true,
                onTap: () => context.push(AppRoutes.consultSymptoms),
              ),
              right: _ServiceTile(
                title: 'Red Médica',
                subtitle: 'Encuentra tu sucursal',
                tag: 'Mapa interactivo',
                tagItalic: true,
                icon: Icons.map_outlined,
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GridRow — par horizontal con divisor vertical
// ─────────────────────────────────────────────────────────────────────────────
class _GridRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _GridRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: left),
        const VerticalDivider(width: 1, color: AppTheme.border),
        Expanded(child: right),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ServiceTile — celda individual del grid
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final bool tagItalic;
  final bool useDoctorIcon;
  final IconData? icon;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.onTap,
    this.tagItalic = false,
    this.useDoctorIcon = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Ícono ─────────────────────────────────────────────────────
            if (useDoctorIcon)
              Image.asset(
                'assets/icons/DoctorGeneral.png',
                width: 56,
                height: 56,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person_rounded,
                  size: 36,
                  color: AppTheme.primary,
                ),
              )
            else if (icon != null)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: AppTheme.primary),
              ),
            const SizedBox(height: 10),

            // ── Título ───────────────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.bodyBold().copyWith(
                fontSize: 14,
                color: AppTheme.brandBlue,
              ),
            ),
            const SizedBox(height: 3),

            // ── Subtítulo ────────────────────────────────────────────────
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTheme.body().copyWith(
                fontSize: 12,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),

            // ── Tag ──────────────────────────────────────────────────────
            Text(
              tag,
              textAlign: TextAlign.center,
              style: AppTheme.caption().copyWith(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontStyle: tagItalic ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
