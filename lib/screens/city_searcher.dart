import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rweather/screens/home.dart';
import 'package:rweather/services/internet_connection_service.dart';
import 'package:rweather/widgets/internet_connection_snackbar.dart';

class CitySearcher extends StatefulWidget {
  final bool
      fromStart; // Indica si se navega a esta pantalla desde el inicio o no
  const CitySearcher({super.key, required this.fromStart});

  @override
  State<CitySearcher> createState() => _CitySearcherState();
}

class _CitySearcherState extends State<CitySearcher> {
  bool isConnected = true;
  late final InternetConnectionService _connectionService;
  final String? googleApiKey = dotenv.env['MAPS_KEY'];
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _connectionService = InternetConnectionService();
    _connectionService.isConnected.addListener(() {
      final connected = _connectionService.isConnected.value;
      if (isConnected == true && connected == true) {
        return;
      } else {
        InternetConnectionSnackbar.show(context, isConnected);
        setState(() {
          isConnected = connected;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectionService.dispose();
    _debounceTimer?.cancel(); // Limpiamos el timer cuando el widget se destruya
    super.dispose();
  }

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
    if (isConnected) {
      // Cancelamos cualquier llamado anterior
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

      // Establecemos un nuevo timer
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        fetchSuggestions(
            query); // Realizamos la llamada después de 300ms de inactividad
      });
    } else {
      InternetConnectionSnackbar.show(context, isConnected);
    }
  }

  void _navigateToHomeScreen(String city) {
    if (widget.fromStart) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(city: city),
        ),
      );
    } else {
      Navigator.pop(context, city);
    }
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
              onChanged:
                  _onSearchChanged, // Llamamos a _onSearchChanged en cada keystroke
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
                      _navigateToHomeScreen(
                          suggestion); // Devolver ciudad seleccionada
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
