import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../account/providers/account_provider.dart';
import '../appointments/providers/appointments_provider.dart';
import 'providers/health_record_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HealthRecordScreen — Diseño FDA Espejo
// ─────────────────────────────────────────────────────────────────────────────
class HealthRecordScreen extends StatefulWidget {
  const HealthRecordScreen({super.key});

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AccountProvider>().fetchProfile();
      context.read<HealthRecordProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mi expediente clínico',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const ListScreenSkeleton();
          final profile = provider.profile;
          if (profile == null) return const ListScreenSkeleton();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionDivider(),

                // ── 1. Fila de Perfil ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      _AvatarRing(url: profile.avatarUrl),
                      const SizedBox(width: 16),
                      Text(
                        profile.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),

                const _ThinDivider(),

                // ── 2. Actividad Reciente (condicional) ────────────────────────
                Consumer<HealthRecordProvider>(
                  builder: (context, hrProvider, _) {
                    final activity = hrProvider.recentActivity;
                    if (activity.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: Text(
                            'Mi actividad reciente',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        ...activity.map((item) => _ActivityListItem(
                          item: item,
                          onTap: () {},
                        )),
                        const _ThinDivider(),
                      ],
                    );
                  },
                ),

                // ── 3. Sección "Mi información" — Carrusel ──────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: const Text(
                    'Mi información',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),

                _VitalsCarousel(vitals: profile.vitalSigns),

                const SizedBox(height: 32),

                // ── 3. Lista de Menú ────────────────────────────────────────
                _MenuListItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Recetas médicas',
                  onTap: () => context.push('/health-record/prescriptions'),
                ),
                _MenuListItem(
                  icon: Icons.vaccines_rounded,
                  label: 'Mis vacunas',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Próximamente: Mis Vacunas'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _MenuListItem(
                  icon: Icons.biotech_rounded,
                  label: 'Resultados de pruebas',
                  onTap: () => context.push('/health-record/documents-list'),
                ),
                _MenuListItem(
                  icon: Icons.medical_services_rounded,
                  label: 'Historial de consultas',
                  onTap: () {
                    // Cargamos citas si no están cargadas y navegamos
                    context.read<AppointmentsProvider>().fetchAppointments();
                    context.push('/appointments');
                  },
                  showDivider: false,
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarRing extends StatelessWidget {
  final String url;
  const _AvatarRing({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.blue, width: 2.5),
      ),
      child: ClipOval(
        child: Container(
          color: AppTheme.primaryLight,
          child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 36),
        ),
      ),
    );
  }
}

class _VitalsCarousel extends StatelessWidget {
  final List<VitalSign> vitals;
  const _VitalsCarousel({required this.vitals});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: vitals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final vital = vitals[i];
          return Container(
            width: 140,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VitalIcon(iconKey: vital.iconKey),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        vital.label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vital.value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vital.date,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VitalIcon extends StatelessWidget {
  final String iconKey;
  const _VitalIcon({required this.iconKey});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (iconKey) {
      case 'blood_drop': iconData = Icons.opacity_rounded; break;
      case 'vitals':     iconData = Icons.favorite_rounded; break;
      case 'science':    iconData = Icons.science_rounded; break;
      case 'monitor_weight': iconData = Icons.monitor_weight_rounded; break;
      case 'height':     iconData = Icons.height_rounded; break;
      case 'blood_type': iconData = Icons.bloodtype_rounded; break;
      default:           iconData = Icons.info_outline_rounded;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(iconData, size: 16, color: const Color(0xFF666666)),
      ),
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuListItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(icon, color: const Color(0xFF444444), size: 24),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFAAAAAA)),
          onTap: onTap,
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: _ThinDivider(),
          ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0));
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE));
}

// ─────────────────────────────────────────────────────────────────────────────
// _ActivityListItem — Row de actividad reciente
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityListItem extends StatelessWidget {
  final RecentActivityItem item;
  final VoidCallback onTap;
  const _ActivityListItem({required this.item, required this.onTap});

  IconData get _icon {
    switch (item.type) {
      case 'vaccine':
        return Icons.vaccines_rounded;
      case 'test':
        return Icons.biotech_rounded;
      case 'prescription':
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Badge properties según status
    final bool isPending = item.status == 'pending_payment';
    final bool isDispensed = item.status == 'dispensed';
    final Color badgeColor = isPending
        ? const Color(0xFFFF9800)
        : isDispensed
            ? const Color(0xFF4CAF50)
            : const Color(0xFF9E9E9E);
    final String badgeLabel = isPending
        ? 'Pendiente de pago'
        : isDispensed
            ? 'Surtida'
            : item.status;

    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, size: 20, color: const Color(0xFF555555)),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Badge de estado
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  item.subtitle!,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF888888)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 2),
              Text(
                item.date,
                style:
                    const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFCCCCCC), size: 20),
          onTap: onTap,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 72),
          child: _ThinDivider(),
        ),
      ],
    );
  }
}

