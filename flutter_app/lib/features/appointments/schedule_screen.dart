import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Doctor> _doctors = [];
  Doctor? _selectedDoctor;
  String? _selectedDate;
  String? _selectedTime;
  bool _isLoading = true;
  bool _isSaving = false;
  String _type = 'video';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final docs = await ApiService.getDoctors();
      setState(() { _doctors = docs; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _schedule() async {
    if (_selectedDoctor == null || _selectedDate == null || _selectedTime == null) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.createAppointment(
        doctorId: _selectedDoctor!.id,
        date: _selectedDate!,
        time: _selectedTime!,
        type: _type,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cita agendada exitosamente!')),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al agendar la cita')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Agendar Cita', style: AppTheme.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: AppTheme.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selecciona un Doctor', style: AppTheme.heading3()),
                  const SizedBox(height: 16),
                  ..._doctors.map((doc) => _DoctorTile(
                    doctor: doc,
                    isSelected: _selectedDoctor?.id == doc.id,
                    onTap: () => setState(() {
                      _selectedDoctor = doc;
                      _selectedTime = null;
                    }),
                  )),
                  if (_selectedDoctor != null) ...[
                    const SizedBox(height: AppTheme.gap),
                    Text('Tipo de Consulta', style: AppTheme.heading3()),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _TypeChip(
                          label: 'Videoconsulta',
                          icon: Icons.videocam_rounded,
                          selected: _type == 'video',
                          onTap: () => setState(() => _type = 'video'),
                        ),
                        const SizedBox(width: 12),
                        _TypeChip(
                          label: 'Presencial',
                          icon: Icons.local_hospital_rounded,
                          selected: _type == 'in-person',
                          onTap: () => setState(() => _type = 'in-person'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.gap),
                    Text('Horario Disponible', style: AppTheme.heading3()),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedDoctor!.availableSlots.map((slot) {
                        final selected = _selectedTime == slot;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTime = slot),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primary : AppTheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(
                                color: selected ? AppTheme.primary : AppTheme.border,
                              ),
                            ),
                            child: Text(
                              slot,
                              style: AppTheme.bodyBold().copyWith(
                                color: selected ? Colors.white : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTheme.gap),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_selectedTime != null && !_isSaving) ? _schedule : null,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Confirmar Cita'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final Doctor doctor;
  final bool isSelected;
  final VoidCallback onTap;

  const _DoctorTile({required this.doctor, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.08) : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name, style: AppTheme.bodyBold()),
                  Text(doctor.specialty, style: AppTheme.caption()),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                const SizedBox(width: 2),
                Text(doctor.rating.toString(), style: AppTheme.caption()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : AppTheme.accent),
            const SizedBox(width: 6),
            Text(label, style: AppTheme.bodyBold().copyWith(color: selected ? Colors.white : AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}
