import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CitySearcher extends StatefulWidget {
  const CitySearcher({super.key});

  @override
  State<CitySearcher> createState() => _CitySearcherState();
}

class _CitySearcherState extends State<CitySearcher> {
  final String? googleApiKey= dotenv.env['MAPS_KEY'];
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];
  Timer? _debounceTimer; // Para manejar el debounce

  // Función que hace la llamada HTTP a la API de Google Places
  Future<void> fetchSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=(cities)&language=es&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List predictions = data['predictions'];

      setState(() {
        suggestions =
            predictions.map<String>((e) => e['description'] as String).toList();
      });
    } else {
      print('Error al obtener sugerencias');
    }
  }

  // Manejamos el debounce en esta función
  void _onSearchChanged(String query) {
    // Cancelamos cualquier llamado anterior
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // Establecemos un nuevo timer
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      fetchSuggestions(query); // Realizamos la llamada después de 300ms de inactividad
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // Limpiamos el timer cuando el widget se destruya
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar ciudad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged, // Llamamos a _onSearchChanged en cada keystroke
              decoration: const InputDecoration(
                hintText: 'Escribe una ciudad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    title: Text(suggestion),
                    onTap: () {
                      Navigator.pop(context, suggestion); // Devolver ciudad seleccionada
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
