import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackgroundImageService {
  // Método que recibe el tipo de clima y devuelve la URL de la imagen desde Unsplash
  Future<String> getImageUrl(String weatherType) async {
    final apiKey = dotenv.env['IMAGES_KEY'];

    // Mapea los tipos de clima a las palabras clave para Unsplash
    String photoId = '';

    switch (weatherType) {
      case 'Clear':
        photoId = 'ROVBDer29PQ';
        break;
      case 'Clouds':
        photoId = 'Pe1Ol9oLc4o';
        break;
      case 'Rain':
        photoId = 'Nw_D8v79PM4';
        break;
      case 'Snow':
        photoId = 'd3pTF3r_hwY';
        break;
      case 'Thunderstorm':
        photoId = 'nbqlWhOVu6k';
        break;
      case 'Drizzle':
        photoId = '7aCMkMYR7S0';
        break;
      case 'Mist':
        photoId = '7CME6Wlgrdk';
        break;
      case 'Smoke':
        photoId = 'Dey08rsZ6TI';
        break;
      case 'Haze':
        photoId = 'of_PAYg4QYE';
        break;
      case 'Dust':
        photoId = 'JnZT941-bc8';
        break;
      case 'Fog':
        photoId = 'obQacWYxB1I';
        break;
      default:
        photoId = 'ROVBDer29PQ';
    }

    // Usamos el endpoint de búsqueda de imágenes en Unsplash con un término relacionado con el clima
    final url = Uri.parse(
      'https://api.unsplash.com/photos/$photoId?client_id=$apiKey',
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
