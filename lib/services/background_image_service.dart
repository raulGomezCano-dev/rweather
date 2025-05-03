import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackgroundImageService {
  // Método que recibe el tipo de clima y devuelve la URL de la imagen desde Unsplash
  Future<String> getImageUrl(String weatherType) async {
    final apiKey = dotenv.env['IMAGES_KEY'];

    // Mapea los tipos de clima a las palabras clave para Unsplash
    String query = '';

    switch (weatherType) {
      case 'Clear':
        query = 'clear-sky';
        break;
      case 'Clouds':
        query = 'cloudy';
        break;
      case 'Rain':
        query = 'rainy';
        break;
      case 'Snow':
        query = 'snow';
        break;
      case 'Thunderstorm':
        query = 'thunderstorm';
        break;
      case 'Drizzle':
        query = 'drizzle';
        break;
      case 'Mist':
        query = 'mist';
        break;
      case 'Smoke':
        query = 'smoke';
        break;
      case 'Haze':
        query = 'haze';
        break;
      case 'Dust':
        query = 'dust';
        break;
      case 'Fog':
        query = 'fog';
        break;
      default:
        query = 'weather';
    }

    // Usamos el endpoint de búsqueda de imágenes en Unsplash con un término relacionado con el clima
    final url = Uri.parse(
      'https://api.unsplash.com/photos/random?query=$query&client_id=$apiKey&orientation=landscape',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final imageUrl = data['urls']?['regular'];

      if (imageUrl != null) {
        return imageUrl;
      } else {
        throw Exception('No se encontró una URL válida en la respuesta.');
      }
    } else {
      throw Exception('Error en la solicitud a Unsplash: ${response.body}');
    }
  }
}
