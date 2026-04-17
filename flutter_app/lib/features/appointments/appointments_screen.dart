import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
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
            onPressed: () => context.push('/appointments/schedule'),
            icon: const Icon(Icons.add_rounded, color: AppTheme.primary),
            label: Text('Nueva', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.accent,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: 'Próximas'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: Consumer<AppointmentsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const ListScreenSkeleton();
          }
          if (provider.error != null) {
            return ErrorBanner(
              onRetry: provider.fetchAppointments,
            );
          }
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
            Icon(Icons.calendar_today_outlined, size: 56, color: AppTheme.accent),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No tienes citas próximas' : 'Sin historial de citas',
              style: AppTheme.body(),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/appointments/schedule'),
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
      itemBuilder: (context, i) => _AppointmentCard(
        appointment: items[i],
        isUpcoming: isUpcoming,
        onTap: () => context.push('/appointments/${items[i].id}'),
        onCancel: isUpcoming
            ? () => context.read<AppointmentsProvider>().cancelAppointment(items[i].id)
            : null,
      ),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.shadowSoft,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 28),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment.doctorName, style: AppTheme.bodyBold()),
                  const SizedBox(height: 2),
                  Text(appointment.doctorSpecialty,
                      style: AppTheme.caption()),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isUpcoming
                              ? AppTheme.primary.withOpacity(0.1)
                              : AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${appointment.date} · ${appointment.time}',
                          style: AppTheme.caption().copyWith(
                            color: isUpcoming ? AppTheme.primary : AppTheme.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        appointment.isVideo
                            ? Icons.videocam_rounded
                            : Icons.local_hospital_rounded,
                        size: 14,
                        color: AppTheme.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            if (isUpcoming && onCancel != null)
              IconButton(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.accent),
              ),
          ],
        ),
      ),
    );
  }
}
