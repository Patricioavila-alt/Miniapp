import 'package:flutter/foundation.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/models.dart';

// ─── Datos demo ───────────────────────────────────────────────────────────────
final List<Appointment> _mockUpcoming = [
  Appointment(
    id: 'appt_001',
    doctorId: 'doc_01',
    doctorName: 'Dr. Alejandro Vega',
    doctorSpecialty: 'Medicina General',
    doctorAvatar: '',
    date: 'Martes, 17 de mayo',
    time: '10:30 am',
    status: 'upcoming',
    type: 'video',
    paymentStatus: 'pending',
    notes: 'Revisión de resultados de laboratorio.',
  ),
  // Cita de Vacuna — Pendiente de pago
  Appointment(
    id: 'appt_vaccine_001',
    doctorId: 'doc_vac_01',
    doctorName: 'Cita para vacuna',
    doctorSpecialty: 'Vacuna VPH',
    doctorAvatar: '',
    date: 'Miércoles, 20 de mayo',
    time: '09:45 am',
    status: 'upcoming',
    type: 'vaccine',
    paymentStatus: 'pending',
    notes: 'Prevén el cáncer cervicouterino. De 9 años en adelante.',
  ),
  // Cita de Prueba — Pendiente de pago
  Appointment(
    id: 'appt_test_001',
    doctorId: 'doc_test_01',
    doctorName: 'Cita para prueba',
    doctorSpecialty: 'Antígeno COVID-19',
    doctorAvatar: '',
    date: 'Viernes, 22 de mayo',
    time: '11:00 am',
    status: 'upcoming',
    type: 'test',
    paymentStatus: 'pending',
    notes: 'Detecta presencia activa del virus SARS-CoV-2. A partir de 2 años.',
  ),
];

final List<Appointment> _mockPast = [
  Appointment(
    id: 'appt_003',
    doctorId: 'doc_01',
    doctorName: 'Dr. Alejandro Vega',
    doctorSpecialty: 'Medicina General',
    doctorAvatar: '',
    date: '03 Mar 2026',
    time: '11:00 AM',
    status: 'completed',
    type: 'video',
    paymentStatus: 'paid',
    notes: 'Consulta de rutina.',
  ),
];

class AppointmentsProvider extends ChangeNotifier {
  List<Appointment> _upcoming = [];
  List<Appointment> _past = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  List<Appointment> get upcoming => _upcoming;
  List<Appointment> get past => _past;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _error = null;
    _notify();
    try {
      _upcoming = await ApiService.getAppointments(status: 'upcoming');
      _past = await ApiService.getAppointments(status: 'past');
    } catch (e, st) {
      debugPrint('[AppointmentsProvider] fetchAppointments: $e\n$st');
      _upcoming = _mockUpcoming;
      _past = _mockPast;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      await ApiService.cancelAppointment(id);
      await fetchAppointments();
    } catch (e) {
      _error = e.toString();
      _notify();
    }
  }
}
