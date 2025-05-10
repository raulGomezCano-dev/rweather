import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CitySearchService {
  final String? apiKey = dotenv.env['MAPS_KEY'];

  /// Buscar sugerencias de ciudades usando Google Places Autocomplete API
  Future<List<Map<String, String>>> buscarCiudades(String input) async {
    if (apiKey == null) throw Exception('API Key no encontrada');

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$input'
      '&types=(cities)'
      '&language=es'
      '&key=$apiKey',
    );

    final response = await http.get(uri);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      return List<Map<String, String>>.from(data['predictions'].map((p) => {
            'description': p['description'],
            'place_id': p['place_id'],
          }));
    } else {
      throw Exception('Error al buscar ciudades: ${data['status']}');
    }
  }

  /// Obtener coordenadas de una ciudad usando Place Details API
  // Future<Map<String, double>> obtenerCoordenadas(String placeId) async {
  Future<Map<String, dynamic>> obtenerCoordenadas(String place) async {
    if (apiKey == null) throw Exception('API Key no encontrada');

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?'
      'address=$place'
      '&key=$apiKey',
    );

    final response = await http.get(uri);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final location = data['results'][0]['geometry']['location'];
      return {
        'lat': location['lat'],
        'lng': location['lng'],
      };
    } else {
      throw Exception('Error al obtener coordenadas: ${data['status']}');
    }
  }
}
