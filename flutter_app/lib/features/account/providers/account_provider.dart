import 'package:flutter/foundation.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/models.dart';

// ─── Datos demo ───────────────────────────────────────────────────────────────
final _mockProfile = UserProfile(
  id: 'user_001',
  fullName: 'Alejandra Méndez',
  email: 'alejandra.mendez@gmail.com',
  phone: '+52 55 1234 5678',
  dateOfBirth: '12 / Mar / 1990',
  gender: 'Femenino',
  bloodType: 'O+',
  weight: '56 KG',
  height: '157 cm',
  allergies: ['Penicilina'],
  avatarUrl: '',
  vitalSigns: [
    VitalSign(label: 'Glucosa', value: '95', date: '04/03/2026', iconKey: 'blood_drop'),
    VitalSign(label: 'Presión arterial', value: '120/80', date: '04/03/2026', iconKey: 'vitals'),
    VitalSign(label: 'Triglicéridos', value: '150', date: '04/03/2026', iconKey: 'science'),
    VitalSign(label: 'Peso', value: '56 KG', date: '04/03/2026', iconKey: 'monitor_weight'),
    VitalSign(label: 'Estatura', value: '157 cm', date: '04/03/2026', iconKey: 'height'),
    VitalSign(label: 'Sangre tipo', value: 'O+', date: '04/03/2026', iconKey: 'blood_type'),
  ],
);

class AccountProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await ApiService.getProfile();
    } catch (_) {
      // Backend no disponible → cargar datos de demostración
      _profile = _mockProfile;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await ApiService.updateProfile(fields);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
