import 'package:flutter/material.dart';
import 'package:rweather/screens/home.dart';
import 'package:rweather/services/city_search_service.dart';
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
            const Image(
              height: 300,
              image: AssetImage('assets/icon/launcher_icon.png'),
            ),
            Text('Consulta con RWeather el tiempo donde quieras'),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () {
                getCurrentPosition(context);
              },
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 119, 168, 168),
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 80)),
              child: const Text(
                'Ver mi ubicación',
                style: TextStyle(
                  fontSize: 25,
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
                backgroundColor: const Color.fromARGB(255, 119, 168, 168),
                fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 80),
              ),
              child: const Text(
                'Buscar ciudad',
                style: TextStyle(
                  fontSize: 25,
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
    final cityService = CitySearchService();
    bool permission = await GeolocatorService.checkPermissions(context);
    if (permission) {
      var location = await GeolocatorService.getCurrentPosition();
      String actualCity = await cityService.getCityFromCoordinates(
          location.latitude.toString(), location.longitude.toString());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(city: actualCity),
        ),
      );
    }
  }
}
