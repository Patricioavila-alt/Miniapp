import 'package:flutter/foundation.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/models.dart';

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
    {'id': 'expediente', 'label': 'Mi expediente\nclínico', 'icon': 'expediente'},
    {'id': 'video',      'label': 'Videoconsulta\nen Medicina g.', 'icon': 'videocam'},
    {'id': 'schedule',   'label': 'Agendar cita\npara vacunas', 'icon': 'calendar'},
    {'id': 'prescription','label': 'Escanear\nrecetas', 'icon': 'medical'},
    {'id': 'pharmacy',   'label': 'Buscar\nFarmacia', 'icon': 'medkit'},
  ],
  promotions: [
    Promotion(
      id: 'promo_01',
      title: 'Fitmingo',
      description: 'Proteína Vegetal. Tu aliado para cuidarte por dentro y por fuera.',
      imageUrl: 'https://images.unsplash.com/photo-1607170208694-c8e3d66c4b51?w=400&q=80',
      ctaText: 'Ver más',
      ctaAction: 'schedule',
    ),
    Promotion(
      id: 'promo_02',
      title: 'Chequeo Preventivo',
      description: 'Agenda tu revisión anual sin costo adicional este mes.',
      imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400&q=80',
      ctaText: 'Agendar',
      ctaAction: 'schedule',
    ),
  ],
);

class HomeProvider extends ChangeNotifier {
  HomeData? _data;
  bool _isLoading = false;
  String? _error;

  HomeData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHome() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await ApiService.getHome();
    } catch (_) {
      // Backend no disponible → cargar datos de demostración
      _data = _mockHomeData;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
