import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Solicita permisos y obtiene la posición actual del dispositivo
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Los servicios de ubicación no están habilitados
      return null;
    }

    // 2. Verificar el estado de los permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Los permisos fueron denegados
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Los permisos están denegados permanentemente
      return null;
    }

    // 3. Cuando todo está correcto, obtener la posición
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Convierte coordenadas a una dirección legible usando OpenStreetMap Nominatim API
  static Future<String?> getAddressFromCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon');
      final response = await http.get(url, headers: {
        'User-Agent': 'misalud_flutter_app', // Requerido por Nominatim
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null) {
          final street = address['road'] ?? address['pedestrian'] ?? '';
          final houseNumber = address['house_number'] ?? '';
          final city = address['city'] ?? address['town'] ?? address['village'] ?? '';
          final postcode = address['postcode'] ?? '';
          final state = address['state'] ?? '';
          
          List<String> parts = [];
          if (street.isNotEmpty) parts.add('$street $houseNumber'.trim());
          if (postcode.isNotEmpty) parts.add(postcode);
          if (city.isNotEmpty) parts.add(city);
          else if (state.isNotEmpty) parts.add(state);
          
          final finalAddress = parts.join(', ');
          return finalAddress.isNotEmpty ? finalAddress : 'Ubicación desconocida';
        }
      }
    } catch (e) {
      print('Error geocoding: $e');
    }
    return null;
  }
}
