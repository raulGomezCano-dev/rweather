import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rweather/models/hourly_weather.dart';
import 'package:rweather/models/weather_info.dart';
import 'package:rweather/services/background_image_service.dart';
import 'package:rweather/services/geocoding_service.dart';
import 'package:rweather/services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final weatherService = WeatherService();
  final backgroundImageService = BackgroundImageService();
  final cityService = CitySearchService();
  final TextEditingController cityController = TextEditingController();

  double temperature = 0;
  double minTemperature = 0;
  double maxTemperature = 0;
  double feelsLike = 0;
  String city = '';
  String description = '';
  double windSpeed = 0;
  WeatherInfo? weatherData;
  List<HourlyWeather> hourlyForecast = [];
  String? backgroundImageUrl;
  bool searchingCity = false;

  @override
  void initState() {
    super.initState();
    loadWeather();
    loadHourlyForecast();
  }

  Future<void> loadWeather() async {
    try {
      final data = await weatherService.fetchCurrentWeather();
      setState(() {
        weatherData = data;
        temperature = weatherData!.temperature;
        minTemperature = weatherData!.minTemperature;
        maxTemperature = weatherData!.maxTemperature;
        city = weatherData!.city;
        description = weatherData!.description;
        feelsLike = weatherData!.feelsLike;
        windSpeed = weatherData!.windSpeed;
        loadBackgroundImage(
            weatherData!.description); // Cambiar el fondo según el clima
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadBackgroundImage(String weatherType) async {
    try {
      final url = await backgroundImageService.getImageUrl(weatherType);
      setState(() {
        backgroundImageUrl = url;
      });
    } catch (e) {
      print('Error al cargar la imagen de fondo: $e');
    }
  }

  Future<void> loadHourlyForecast() async {
    try {
      final data = await weatherService.fetchHourlyForecast();
      setState(() {
        hourlyForecast = data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    String weatherType = weatherData?.weatherType ??
        'Clear'; // Por defecto 'Clear' si no se obtiene
    // String backgroundImageUrl = backgroundImageService.getImageUrl(weatherType);

    return Scaffold(
      body: weatherData == null || backgroundImageUrl == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await loadWeather();
                await loadHourlyForecast();
                setState(() {
                  searchingCity = false;
                });
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(backgroundImageUrl!),
                      fit: BoxFit.cover,
                    ),
                    color: const Color.fromARGB(255, 9, 120, 135).withAlpha(55),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        if (searchingCity)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 0, 0, 0)
                                      .withAlpha(0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            width: MediaQuery.of(context).size.width / 2,
                            child: TextField(
                              controller: cityController,
                              style: const TextStyle(color: Colors.white70),
                              decoration: const InputDecoration(
                                isDense: true,
                                hintText: 'Ingresa una ciudad',
                                hintStyle: TextStyle(color: Colors.white70),
                                border: InputBorder
                                    .none, // Eliminamos el borde nativo
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                searchingCity = true;
                                cityService.obtenerCoordenadas('Guadalajara');
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 0, 0)
                                      .withAlpha(0),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.white70,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Buscar ciudad',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () {}, child: const Text('Ayer')),
                            TextButton(
                                onPressed: () {}, child: const Text('Hoy')),
                            TextButton(
                                onPressed: () {}, child: const Text('Mañana'))
                          ],
                        ),
                        Image.network(
                          'https://openweathermap.org/img/wn/${weatherData!.icon}@2x.png',
                          width: 100,
                          height: 100,
                        ),
                        Text(weatherData!.description),
                        Text(city),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.wind_power),
                                Text('$windSpeed m/s')
                              ],
                            ),
                            Column(
                              children: [
                                Text('$temperatureºC'),
                                Text('Sensación de $feelsLikeºC')
                              ],
                            ),
                            Column(
                              children: [
                                Text('Min. $minTemperature'),
                                Text('Max. $maxTemperature')
                              ],
                            )
                          ],
                        ),
                        hourlyForecast.isEmpty
                            ? const Text('Fallo en predicción')
                            : SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: hourlyForecast.length,
                                  itemBuilder: (context, index) {
                                    final item = hourlyForecast[index];
                                    final hour =
                                        TimeOfDay.fromDateTime(item.dateTime)
                                            .format(context);
                                    final rainChance = (item.probOfRain * 100)
                                        .toStringAsFixed(0);

                                    return Card(
                                      color: const Color.fromARGB(255, 0, 0, 0)
                                          .withAlpha(0),
                                      margin: const EdgeInsets.all(8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              hour,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Image.network(
                                              'https://openweathermap.org/img/wn/${item.icon}@2x.png',
                                              width: 50,
                                              height: 50,
                                            ),
                                            Text('${item.temperature}ºC'),
                                            Text('$rainChance% lluvia',
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
