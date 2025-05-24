import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CitySearchService {
  final String? apiKey = dotenv.env['MAPS_KEY'];

  // Buscar sugerencias de ciudades usando Google Places Autocomplete API
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

  // Obtener coordenadas de una ciudad usando Place Details API
  Future<Map<String, dynamic>> getCoordinates(String place) async {
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

  // Obtener la ciudad a través de las coordenadas (para la ubicación)
  Future<String> getCityFromCoordinates(String lat, String lon) async {
    if (apiKey == null) throw Exception('API Key no encontrada');

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?'
      'latlng=$lat,$lon'
      '&language=es'
      '&key=$apiKey',
    );

    final response = await http.get(uri);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final results = data['results'] as List;
      for (var result in results) {
        for (var component in result['address_components']) {
          if (component['types'].contains('locality')) {
            return component['long_name'];
          }
        }
      }
      throw Exception('Ciudad no encontrada en los resultados');
    } else {
      throw Exception('Error al obtener ciudad: ${data['status']}');
    }
  }
}
