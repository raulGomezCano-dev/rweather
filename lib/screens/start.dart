import 'package:flutter/material.dart';
import 'package:rweather/screens/home.dart';
import 'package:rweather/services/geolocator_service.dart';
import 'city_searcher.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 205, 195),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  'LOGO',
                  style: TextStyle(fontSize: 24, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                getCurrentPosition(context);
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: const Color.fromARGB(255, 119, 168, 168),
              ),
              child: const Text(
                'Ver mi ubicación',
                style: TextStyle(
                  color: Color.fromARGB(255, 207, 205, 195),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final selectedCity = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CitySearcher(
                      fromStart: true,
                    ),
                  ),
                );

                if (selectedCity != null && selectedCity is String) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(city: selectedCity),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 119, 168, 168)),
              child: const Text(
                'Buscar ciudad',
                style: TextStyle(
                  color: Color.fromARGB(255, 207, 205, 195),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getCurrentPosition(BuildContext context) async {
    bool permission = await GeolocatorService.checkPermissions(context);
    if (permission) {
      var location = await GeolocatorService.getCurrentPosition();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ubicacion: $location'),
        ),
      );
    }
  }
}
