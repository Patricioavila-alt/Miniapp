import 'package:flutter/foundation.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/models.dart';
import '../../../core/services/location_service.dart';

// ─── Datos demo (se usan cuando el backend no está disponible) ────────────────
final _mockHomeData = HomeData(
  userName: 'Alejandra Méndez',
  smartWidget: {
    'type': 'next_appointment',
    'data': {
      'doctor_name': 'Dr. Alejandro Vega',
      'doctor_specialty': 'Medicina General',
      'date': '17 Abr 2026',
      'time': '10:30 AM',
      'appointment_id': 'appt_001',
    },
  },
  quickActions: [
    {'id': 'video',        'label': 'Videoconsulta\nen Medicina g...', 'icon': 'VideoConsulta'},
    {'id': 'schedule',     'label': 'Agendar cita\npara vacunas', 'icon': 'Citas'},
    {'id': 'prescription', 'label': 'Escanear\nrecetas', 'icon': 'RecetaIA'},
    {'id': 'tests',        'label': 'Agendar cita\npara pruebas', 'icon': 'CitaPruebas'},
    {'id': 'records',      'label': 'Expediente\nMédico', 'icon': 'Expediente'},
  ],
  promotions: [
    Promotion(
      id: 'promo_01',
      title: 'Fitmingo',
      description: 'Proteína Vegetal. Tu aliado para cuidarte por dentro y por fuera.',
      imageUrl: 'https://images.unsplash.com/photo-1579722820308-d74e571900a9?q=80&w=400&auto=format&fit=crop', // A working fitness/protein image
      ctaText: 'Ver más',
      ctaAction: 'schedule',
    ),
    Promotion(
      id: 'promo_02',
      title: 'Chequeo Preventivo',
      description: 'Agenda tu revisión anual sin costo adicional este mes.',
      imageUrl: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?q=80&w=400&auto=format&fit=crop', // Medical checkup image
      ctaText: 'Agendar',
      ctaAction: 'schedule',
    ),
  ],
);

class HomeProvider extends ChangeNotifier {
  HomeData? _data;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  
  String _currentAddress = 'Buscando tu ubicación...';

  HomeData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentAddress => _currentAddress;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchHome() async {
    _isLoading = true;
    _error = null;
    _notify();
    try {
      _data = await ApiService.getHome();
    } catch (e, st) {
      debugPrint('[HomeProvider] fetchHome: $e\n$st');
      _data = _mockHomeData;
    } finally {
      _isLoading = false;
      _notify();
    }
    
    // Al terminar de cargar la info, pedir geolocalización
    await _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (address != null) {
          _currentAddress = address;
        } else {
          _currentAddress = 'Ubicación no disponible';
        }
      } else {
        _currentAddress = 'Permiso denegado / GPS inactivo';
      }
    } catch (e) {
      _currentAddress = 'Error al ubicar';
    }
    _notify();
  }
}
