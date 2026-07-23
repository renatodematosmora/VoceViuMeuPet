// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Coordenadas de geolocalização
class GeolocationCoordinates {
  final double latitude;
  final double longitude;

  const GeolocationCoordinates({
    required this.latitude,
    required this.longitude,
  });
}

/// Serviço centralizado de geolocalização e reverse geocoding
class GeolocationService {
  /// Obtém a localização atual do dispositivo/browser
  /// Retorna null se não conseguir obter
  static Future<GeolocationCoordinates?> getCurrentLocation() async {
    try {
      final geo = html.window.navigator.geolocation;
      final pos = await geo.getCurrentPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 15),
      );
      final coords = pos.coords;
      if (coords == null || coords.latitude == null || coords.longitude == null) {
        return null;
      }
      return GeolocationCoordinates(
        latitude: coords.latitude!.toDouble(),
        longitude: coords.longitude!.toDouble(),
      );
    } catch (e) {
      print('[GeolocationService] Erro ao obter localização: $e');
      return null;
    }
  }

  /// Converte coordenadas em endereço usando Nominatim (OSM)
  /// Retorna string formatada com endereço ou "Lat: X, Lng: Y" se falhar
  static Future<String> reverseGeocode(double lat, double lng) async {
    String addressStr = 'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}';
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&accept-language=pt-BR',
      );
      final request = await html.HttpRequest.request(
        url.toString(),
        method: 'GET',
        requestHeaders: {'User-Agent': 'VoceViuMeuPet/1.0'},
      );
      if (request.status == 200 && request.responseText != null) {
        final raw = request.responseText!;
        final start = raw.indexOf('"display_name":"');
        if (start != -1) {
          final cut = raw.substring(start + 16);
          final end = cut.indexOf('"');
          if (end != -1) {
            addressStr = cut.substring(0, end)
                .replaceAll(r'\"', '"')
                .replaceAll(r'\\', r'\');
          }
        }
      }
    } catch (e) {
      print('[GeolocationService] Erro ao fazer reverse geocode: $e');
    }
    return addressStr;
  }
}
