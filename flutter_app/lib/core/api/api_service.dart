import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

// ─── ApiService ───────────────────────────────────────────────────────────────
// Única clase que realiza llamadas HTTP. Las pantallas y providers NUNCA
// usan http.get() directamente — siempre van a través de esta clase.
class ApiService {
  static const String _baseUrl = 'http://localhost:8000';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ─── Helper interno ────────────────────────────────────────────────────────
  static Future<dynamic> _get(String path) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error ${response.statusCode} en GET $path');
  }

  static Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error ${response.statusCode} en POST $path');
  }

  static Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error ${response.statusCode} en PUT $path');
  }

  static Future<void> _delete(String path) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error ${response.statusCode} en DELETE $path');
    }
  }

  // ─── Home ──────────────────────────────────────────────────────────────────
  static Future<HomeData> getHome() async {
    final data = await _get('/api/home');
    return HomeData.fromJson(data);
  }

  // ─── Doctors ───────────────────────────────────────────────────────────────
  static Future<List<Doctor>> getDoctors({String? search}) async {
    final query = search != null ? '?search=${Uri.encodeComponent(search)}' : '';
    final data = await _get('/api/doctors$query') as List<dynamic>;
    return data.map((d) => Doctor.fromJson(d)).toList();
  }

  static Future<Doctor> getDoctor(String doctorId) async {
    final data = await _get('/api/doctors/$doctorId');
    return Doctor.fromJson(data);
  }

  // ─── Appointments ──────────────────────────────────────────────────────────
  static Future<List<Appointment>> getAppointments({String? status}) async {
    final query = status != null ? '?status=$status' : '';
    final data = await _get('/api/appointments$query') as List<dynamic>;
    return data.map((a) => Appointment.fromJson(a)).toList();
  }

  static Future<Appointment> getAppointment(String id) async {
    final data = await _get('/api/appointments/$id');
    return Appointment.fromJson(data);
  }

  static Future<Appointment> createAppointment({
    required String doctorId,
    required String date,
    required String time,
    String type = 'video',
    String? notes,
  }) async {
    final data = await _post('/api/appointments', {
      'doctor_id': doctorId,
      'date': date,
      'time': time,
      'type': type,
      if (notes != null) 'notes': notes,
    });
    return Appointment.fromJson(data);
  }

  static Future<void> cancelAppointment(String id) async {
    await _delete('/api/appointments/$id');
  }

  // ─── Prescriptions ─────────────────────────────────────────────────────────
  static Future<List<Prescription>> getPrescriptions() async {
    final data = await _get('/api/prescriptions') as List<dynamic>;
    return data.map((p) => Prescription.fromJson(p)).toList();
  }

  static Future<Prescription> getPrescription(String id) async {
    final data = await _get('/api/prescriptions/$id');
    return Prescription.fromJson(data);
  }

  // ─── Clinical Documents ────────────────────────────────────────────────────
  static Future<List<ClinicalDocument>> getDocuments() async {
    final data = await _get('/api/documents') as List<dynamic>;
    return data.map((d) => ClinicalDocument.fromJson(d)).toList();
  }

  static Future<ClinicalDocument> getDocument(String id) async {
    final data = await _get('/api/documents/$id');
    return ClinicalDocument.fromJson(data);
  }

  // ─── Signature Documents ───────────────────────────────────────────────────
  static Future<List<SignatureDocument>> getSignatureDocuments() async {
    final data = await _get('/api/signature-documents') as List<dynamic>;
    return data.map((d) => SignatureDocument.fromJson(d)).toList();
  }

  static Future<void> signDocument(String id) async {
    await _post('/api/signature-documents/$id/sign', {});
  }

  // ─── Profile ───────────────────────────────────────────────────────────────
  static Future<UserProfile> getProfile() async {
    final data = await _get('/api/profile');
    return UserProfile.fromJson(data);
  }

  static Future<UserProfile> updateProfile(Map<String, dynamic> fields) async {
    final data = await _put('/api/profile', fields);
    return UserProfile.fromJson(data);
  }

  // ─── Promotions ────────────────────────────────────────────────────────────
  static Future<List<Promotion>> getPromotions() async {
    final data = await _get('/api/promotions') as List<dynamic>;
    return data.map((p) => Promotion.fromJson(p)).toList();
  }
}
