import 'package:flutter/foundation.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/models.dart';

// ─── Datos demo ───────────────────────────────────────────────────────────────
final _mockUpcoming = [
  Appointment(
    id: 'appt_001',
    doctorId: 'doc_01',
    doctorName: 'Dr. Alejandro Vega',
    doctorSpecialty: 'Medicina General',
    doctorAvatar: '',
    date: '17 Abr 2026',
    time: '10:30 AM',
    status: 'upcoming',
    type: 'video',
    notes: 'Revisión de resultados de laboratorio.',
  ),
  Appointment(
    id: 'appt_002',
    doctorId: 'doc_02',
    doctorName: 'Dra. Sofía Ramírez',
    doctorSpecialty: 'Cardiología',
    doctorAvatar: '',
    date: '22 Abr 2026',
    time: '09:00 AM',
    status: 'upcoming',
    type: 'in-person',
    notes: 'Seguimiento de presión arterial.',
  ),
];

final _mockPast = [
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
    notes: 'Consulta de rutina.',
  ),
];

class AppointmentsProvider extends ChangeNotifier {
  List<Appointment> _upcoming = [];
  List<Appointment> _past = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get upcoming => _upcoming;
  List<Appointment> get past => _past;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _upcoming = await ApiService.getAppointments(status: 'upcoming');
      _past = await ApiService.getAppointments(status: 'past');
    } catch (_) {
      // Backend no disponible → cargar datos de demostración
      _upcoming = _mockUpcoming;
      _past = _mockPast;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      await ApiService.cancelAppointment(id);
      await fetchAppointments();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
