import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

// ─── ApiService ───────────────────────────────────────────────────────────────
// Único punto de contacto con el backend. Ningún provider llama http directamente.
// El user_id activo se inyecta automáticamente en cada request vía X-User-Id.
class ApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  static const Duration _timeout = Duration(seconds: 15);

  static String _currentUserId = 'user-001';

  // Llamar al seleccionar usuario. Lanza si el id está vacío.
  static void setCurrentUser(String userId) {
    assert(userId.isNotEmpty, 'userId no puede ser vacío');
    _currentUserId = userId;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-User-Id': _currentUserId,
      };

  // ─── Helpers ───────────────────────────────────────────────────────────────
  static Future<dynamic> _get(String path) async {
    final response = await http
        .get(Uri.parse('$_baseUrl$path'), headers: _headers)
        .timeout(_timeout);
    if (response.statusCode == 200)
      return jsonDecode(utf8.decode(response.bodyBytes));
    throw Exception('Error ${response.statusCode} en GET $path');
  }

  static Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final response = await http
        .post(Uri.parse('$_baseUrl$path'),
            headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);
    if (response.statusCode == 200 || response.statusCode == 201)
      return jsonDecode(utf8.decode(response.bodyBytes));
    final detail = _parseError(response.body);
    throw Exception(detail);
  }

  static Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final response = await http
        .put(Uri.parse('$_baseUrl$path'),
            headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);
    if (response.statusCode == 200)
      return jsonDecode(utf8.decode(response.bodyBytes));
    throw Exception('Error ${response.statusCode} en PUT $path');
  }

  static Future<void> _delete(String path) async {
    final response = await http
        .delete(Uri.parse('$_baseUrl$path'), headers: _headers)
        .timeout(_timeout);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error ${response.statusCode} en DELETE $path');
    }
  }

  static String _parseError(String body) {
    try {
      final json = jsonDecode(body);
      return json['detail']?.toString() ?? 'Error desconocido';
    } catch (_) {
      return body;
    }
  }

  // ─── Users ─────────────────────────────────────────────────────────────────
  static Future<List<UserListItem>> getUsers() async {
    final data = await _get('/api/users') as List<dynamic>;
    return data.map((u) => UserListItem.fromJson(u)).toList();
  }

  // ─── Home ──────────────────────────────────────────────────────────────────
  static Future<HomeData> getHome() async {
    final data = await _get('/api/home');
    return HomeData.fromJson(data);
  }

  // ─── Doctors ───────────────────────────────────────────────────────────────
  static Future<List<Doctor>> getDoctors({String? search}) async {
    final query =
        search != null ? '?search=${Uri.encodeComponent(search)}' : '';
    final data = await _get('/api/doctors$query') as List<dynamic>;
    return data.map((d) => Doctor.fromJson(d)).toList();
  }

  static Future<Doctor> getDoctor(String doctorId) async {
    final data = await _get('/api/doctors/$doctorId');
    return Doctor.fromJson(data);
  }

  // ─── Branches ──────────────────────────────────────────────────────────────
  static Future<List<Branch>> getBranches({String? service}) async {
    final query = service != null ? '?service=$service' : '';
    final data = await _get('/api/branches$query') as List<dynamic>;
    return data.map((b) => Branch.fromJson(b)).toList();
  }

  // ─── Vaccine Types ─────────────────────────────────────────────────────────
  static Future<List<VaccineType>> getVaccineTypes() async {
    final data = await _get('/api/vaccine-types') as List<dynamic>;
    return data.map((v) => VaccineType.fromJson(v)).toList();
  }

  // ─── Test Types ────────────────────────────────────────────────────────────
  static Future<List<TestType>> getTestTypes() async {
    final data = await _get('/api/test-types') as List<dynamic>;
    return data.map((t) => TestType.fromJson(t)).toList();
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

  static Future<Appointment> createAppointment(
      Map<String, dynamic> body) async {
    final data = await _post('/api/appointments', body);
    return Appointment.fromJson(data);
  }

  static Future<void> cancelAppointment(String id) async {
    await _delete('/api/appointments/$id');
  }

  // ─── Payment ───────────────────────────────────────────────────────────────
  static Future<PaymentResult> processPayment({
    required String cardNumber,
    required double amount,
    String? appointmentId,
  }) async {
    final data = await _post('/api/payment/process', {
      'card_number': cardNumber,
      'amount': amount,
      if (appointmentId != null) 'appointment_id': appointmentId,
    });
    return PaymentResult.fromJson(data);
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

  // ─── Recent Activity ───────────────────────────────────────────────────────
  static Future<List<RecentActivityItem>> getRecentActivity() async {
    final data = await _get('/api/recent-activity') as List<dynamic>;
    return data.map((a) => RecentActivityItem.fromJson(a)).toList();
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

  // ─── Prescription AI Validation ────────────────────────────────────────────
  // Sube el archivo de receta al backend y retorna la validación IA.
  // [filePath] puede ser imagen (JPG/PNG) o documento (PDF) del dispositivo.
  static Future<Map<String, dynamic>> validatePrescription(
      String filePath) async {
    final uri = Uri.parse('$_baseUrl/api/prescriptions/validate');
    final request = http.MultipartRequest('POST', uri)
      ..headers['X-User-Id'] = _currentUserId;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    }
    throw Exception(_parseError(response.body));
  }

  // ─── Promotions ────────────────────────────────────────────────────────────
  static Future<List<Promotion>> getPromotions() async {
    final data = await _get('/api/promotions') as List<dynamic>;
    return data.map((p) => Promotion.fromJson(p)).toList();
  }

  static Future<void> updatePromotionImage(
      String promoId, String imageUrl) async {
    await _put('/api/promotions/$promoId/image', {'image_url': imageUrl});
  }
}
