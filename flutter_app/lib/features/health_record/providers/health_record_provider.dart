import 'package:flutter/foundation.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/models.dart';

// ─── Actividad reciente demo ───────────────────────────────────────────────
final _mockRecentActivity = [
  RecentActivityItem(
    id: 'act_001',
    title: 'Vacuna VPH',
    date: '20 nov, 09:45 am',
    status: 'pending_payment',
    type: 'vaccine',
  ),
  RecentActivityItem(
    id: 'act_002',
    title: 'Antígeno COVID-19',
    date: '20 nov, 09:45 am',
    status: 'pending_payment',
    type: 'test',
  ),
  RecentActivityItem(
    id: 'act_003',
    title: 'RX-2026-001245',
    subtitle: 'Infección respiratoria viral aguda',
    date: '11 feb 2026',
    status: 'dispensed',
    type: 'prescription',
  ),
];

// ─── Datos demo ───────────────────────────────────────────────────────────────────
final _mockPrescriptions = [
  Prescription(
    id: 'rx_001',
    doctorName: 'Dr. Alejandro Vega',
    doctorSpecialty: 'Medicina General',
    date: '03 Mar 2026',
    diagnosis: 'Infección respiratoria aguda',
    medications: [
      Medication(name: 'Amoxicilina 500mg', dosage: '1 cápsula cada 8h', duration: '7 días'),
      Medication(name: 'Paracetamol 500mg', dosage: '1 tableta cada 6h', duration: '3 días'),
    ],
    notes: 'Reposo, abundantes líquidos.',
    qrCodeData: 'RX-FDA-001-2026',
    status: 'active',
  ),
  Prescription(
    id: 'rx_002',
    doctorName: 'Dra. Sofía Ramírez',
    doctorSpecialty: 'Cardiología',
    date: '15 Ene 2026',
    diagnosis: 'Hipertensión arterial leve',
    medications: [
      Medication(name: 'Losartán 50mg', dosage: '1 tableta diaria', duration: '30 días'),
    ],
    notes: 'Dieta baja en sodio, ejercicio moderado.',
    qrCodeData: 'RX-FDA-002-2026',
    status: 'completed',
  ),
];

final _mockDocuments = [
  ClinicalDocument(
    id: 'doc_001',
    title: 'Resultados de Laboratorio',
    type: 'lab_result',
    date: '10 Mar 2026',
    doctorName: 'Dr. Alejandro Vega',
    summary: 'Biometría hemática, química sanguínea y examen general de orina. Resultados en parámetros normales.',
    status: 'available',
  ),
  ClinicalDocument(
    id: 'doc_002',
    title: 'Resumen de Consulta Cardiológica',
    type: 'consultation_summary',
    date: '22 Ene 2026',
    doctorName: 'Dra. Sofía Ramírez',
    summary: 'Paciente con hipertensión arterial controlada. Se ajusta tratamiento farmacológico.',
    status: 'available',
  ),
];

final _mockSignatureDocs = [
  SignatureDocument(
    id: 'sign_001',
    title: 'Consentimiento Informado — Videoconsulta',
    type: 'consent_form',
    date: '17 Abr 2026',
    status: 'pending',
    contentPreview: 'Al aceptar este documento, autoriza a Farmacias del Ahorro a realizar videoconsultas médicas en su nombre...',
  ),
  SignatureDocument(
    id: 'sign_002',
    title: 'Aviso de Privacidad',
    type: 'privacy_policy',
    date: '01 Ene 2026',
    status: 'signed',
    contentPreview: 'Sus datos personales son tratados conforme a la legislación vigente en México...',
  ),
];

class HealthRecordProvider extends ChangeNotifier {
  List<Prescription> _prescriptions = [];
  List<ClinicalDocument> _documents = [];
  List<SignatureDocument> _signatureDocs = [];
  List<RecentActivityItem> _recentActivity = [];
  bool _isLoading = false;
  String? _error;

  List<Prescription> get prescriptions => _prescriptions;
  List<ClinicalDocument> get documents => _documents;
  List<SignatureDocument> get signatureDocs => _signatureDocs;
  /// Lista vacía significa que el usuario NO tiene actividad reciente
  List<RecentActivityItem> get recentActivity => _recentActivity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _prescriptions = await ApiService.getPrescriptions();
      _documents = await ApiService.getDocuments();
      _signatureDocs = await ApiService.getSignatureDocuments();
      // TODO: reemplazar con ApiService.getRecentActivity() cuando esté disponible
      _recentActivity = [];
    } catch (_) {
      // Backend no disponible → datos de demo
      _prescriptions = _mockPrescriptions;
      _documents = _mockDocuments;
      _signatureDocs = _mockSignatureDocs;
      _recentActivity = _mockRecentActivity;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signDocument(String id) async {
    try {
      await ApiService.signDocument(id);
      await fetchAll();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
