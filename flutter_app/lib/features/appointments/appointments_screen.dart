import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/widgets/skeleton_loader.dart';
import 'providers/appointments_provider.dart';
import '../../core/models/models.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(
      () => context.read<AppointmentsProvider>().fetchAppointments(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Mis Citas', style: AppTheme.heading2()),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.scheduleType),
            icon: const Icon(Icons.add_rounded, color: AppTheme.primary),
            label: const Text('Nueva', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.accent,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 2,
          tabs: const [Tab(text: 'Próximas'), Tab(text: 'Historial')],
        ),
      ),
      body: Consumer<AppointmentsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const ListScreenSkeleton();
          if (provider.error != null) return ErrorBanner(onRetry: provider.fetchAppointments);
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider.upcoming, isUpcoming: true),
              _buildList(provider.past, isUpcoming: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<Appointment> items, {required bool isUpcoming}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 56, color: AppTheme.accent),
            const SizedBox(height: 16),
            Text(isUpcoming ? 'No tienes citas próximas' : 'Sin historial de citas', style: AppTheme.body()),
            if (isUpcoming) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.scheduleType),
                child: const Text('Agendar Cita'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final appt = items[i];
        // Determinar ruta de destino según tipo
        String detailRoute;
        if (appt.isVaccine) {
          detailRoute = '/appointments/${appt.id}';
        } else if (appt.isTest) {
          detailRoute = '/test/validating';
        } else {
          detailRoute = '/appointments/${appt.id}';
        }
        return _AppointmentCard(
          appointment: appt,
          isUpcoming: isUpcoming,
          onTap: () => context.push(detailRoute),
          onCancel: isUpcoming
              ? () => context.read<AppointmentsProvider>().cancelAppointment(appt.id)
              : null,
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isUpcoming;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  const _AppointmentCard({
    required this.appointment,
    required this.isUpcoming,
    required this.onTap,
    this.onCancel,
  });

  /// Devuelve ícono, colores de fondo y acento según el tipo de cita
  _TypeStyle _typeStyle() {
    if (appointment.isVaccine) {
      return _TypeStyle(
        icon: Icons.vaccines_rounded,
        bgColor: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF2E7D32),
        label: 'Vacunación',
        labelColor: const Color(0xFF2E7D32),
        labelBg: const Color(0xFFE8F5E9),
      );
    } else if (appointment.isTest) {
      return _TypeStyle(
        icon: Icons.biotech_rounded,
        bgColor: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF1D4ED8),
        label: 'Estudio',
        labelColor: const Color(0xFF1D4ED8),
        labelBg: const Color(0xFFEFF6FF),
      );
    } else if (appointment.isVideo) {
      return _TypeStyle(
        icon: Icons.videocam_rounded,
        bgColor: AppTheme.primaryLight,
        iconColor: AppTheme.primary,
        label: 'Videoconsulta',
        labelColor: AppTheme.primary,
        labelBg: AppTheme.primaryLight,
      );
    } else {
      return _TypeStyle(
        icon: Icons.local_hospital_rounded,
        bgColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFE65100),
        label: 'Presencial',
        labelColor: const Color(0xFFE65100),
        labelBg: const Color(0xFFFFF3E0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = _typeStyle();
    final isPendingPayment = appointment.paymentStatus == 'pending';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isPendingPayment && isUpcoming
                ? const Color(0xFFFED7AA) // naranja suave si pendiente de pago
                : AppTheme.border,
          ),
          boxShadow: AppTheme.shadowSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Ícono de tipo de cita
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: ts.bgColor, shape: BoxShape.circle),
                  child: Icon(ts.icon, color: ts.iconColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.doctorName, style: AppTheme.bodyBold()),
                      const SizedBox(height: 2),
                      Text(appointment.doctorSpecialty, style: AppTheme.caption()),
                      const SizedBox(height: 6),
                      Row(children: [
                        // Tipo badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: ts.labelBg, borderRadius: BorderRadius.circular(20)),
                          child: Text(ts.label,
                              style: AppTheme.caption().copyWith(color: ts.labelColor, fontWeight: FontWeight.w600, fontSize: 11)),
                        ),
                        const SizedBox(width: 6),
                        // Fecha/hora badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isUpcoming ? AppTheme.primary.withOpacity(0.1) : AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${appointment.date} · ${appointment.time}',
                            style: AppTheme.caption().copyWith(
                                color: isUpcoming ? AppTheme.primary : AppTheme.accent,
                                fontWeight: FontWeight.w600, fontSize: 11),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                if (isUpcoming && onCancel != null)
                  IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.accent),
                  ),
              ],
            ),
            // Badge de pago pendiente (solo en próximas)
            if (isUpcoming && isPendingPayment) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.schedule_rounded, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Pago pendiente · Completa tu pago',
                      style: AppTheme.caption().copyWith(color: AppTheme.warning, fontWeight: FontWeight.w600))),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.warning, size: 12),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeStyle {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final Color labelBg;
  const _TypeStyle({
    required this.icon, required this.bgColor, required this.iconColor,
    required this.label, required this.labelColor, required this.labelBg,
  });
}
