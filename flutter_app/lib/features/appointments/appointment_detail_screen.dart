import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  Appointment? _appointment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final apt = await ApiService.getAppointment(widget.appointmentId);
      setState(() { _appointment = apt; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Detalle de Cita', style: AppTheme.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _appointment == null
              ? Center(child: Text('Cita no encontrada', style: AppTheme.body()))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final apt = _appointment!;
    return SingleChildScrollView(
      padding: AppTheme.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3D5E52),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                Text(apt.doctorName,
                    style: AppTheme.heading2().copyWith(color: Colors.white)),
                Text(apt.doctorSpecialty,
                    style: AppTheme.body().copyWith(color: AppTheme.accent)),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.gap),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _DetailRow(icon: Icons.calendar_today_rounded, label: 'Fecha', value: apt.date),
                const Divider(color: AppTheme.border, height: 24),
                _DetailRow(icon: Icons.access_time_rounded, label: 'Hora', value: apt.time),
                const Divider(color: AppTheme.border, height: 24),
                _DetailRow(
                  icon: apt.isVideo ? Icons.videocam_rounded : Icons.local_hospital_rounded,
                  label: 'Tipo',
                  value: apt.isVideo ? 'Videoconsulta' : 'Presencial',
                ),
                if (apt.notes.isNotEmpty) ...[
                  const Divider(color: AppTheme.border, height: 24),
                  _DetailRow(icon: Icons.notes_rounded, label: 'Notas', value: apt.notes),
                ],
              ],
            ),
          ),
          if (apt.isUpcoming && apt.isVideo) ...[
            const SizedBox(height: AppTheme.gap),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/video-call'),
                icon: const Icon(Icons.videocam_rounded),
                label: const Text('Unirse a Videoconsulta'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Text(label, style: AppTheme.caption()),
        const Spacer(),
        Text(value, style: AppTheme.bodyBold()),
      ],
    );
  }
}
