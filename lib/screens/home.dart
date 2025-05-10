import 'package:flutter/material.dart';
import 'package:rweather/models/hourly_weather.dart';
import 'package:rweather/models/weather_info.dart';
import 'package:rweather/screens/city_searcher.dart';
import 'package:rweather/services/background_image_service.dart';
import 'package:rweather/services/city_search_service.dart';
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

  String lat = '40.4531';
  String lon = '-3.6883';

  int temperature = 0;
  int minTemperature = 0;
  int maxTemperature = 0;
  int feelsLike = 0;
  String city = '';
  String description = '';
  int windSpeed = 0;
  WeatherInfo? weatherData;
  List<HourlyWeather> hourlyForecast = [];
  String? backgroundImageUrl;
  bool searchingCity = false;
  bool darkCard = false;

  @override
  void initState() {
    super.initState();
    loadWeather();
    loadHourlyForecast();
  }

  Future<void> loadWeather() async {
    try {
      final data = await weatherService.fetchCurrentWeather(lat, lon);
      setState(() {
        weatherData = data;
        temperature = weatherData!.temperature;
        minTemperature = weatherData!.minTemperature;
        maxTemperature = weatherData!.maxTemperature;
        description = weatherData!.description;
        feelsLike = weatherData!.feelsLike;
        windSpeed = weatherData!.windSpeed;
        loadBackgroundImage(
            weatherData!.weatherType); // Cambiar el fondo según el clima
        // Cambiar el color de Cards y sus Text dependiendo del fondo
        if(weatherData!.weatherType == 'Clear' || weatherData!.weatherType == 'Clouds'){
          darkCard = true;
        }
        else{
          darkCard = false;
        }
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
      final data = await weatherService.fetchHourlyForecast(lat, lon);
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
                              color: Color.fromARGB(255, 0, 0, 0).withAlpha(0),
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
                            onPressed: () async {
                              city = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CitySearcher()),
                              );

                              final coords =
                                  await cityService.obtenerCoordenadas(city);
                              setState(() {
                                lat = coords['lat'].toString();
                                lon = coords['lng'].toString();
                              });
                              await loadWeather();
                              await loadHourlyForecast();
                              setState(() {
                                searchingCity = false;
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
                                const Icon(Icons.wind_power),
                                Text('$windSpeed m/s')
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '$temperatureºC',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48),
                                ),
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
                                      color: darkCard
                                          ? const Color.fromARGB(
                                                  255, 220, 220, 220)
                                              .withAlpha(80)
                                          : const Color.fromARGB(255, 0, 0, 0)
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
                                              style: TextStyle(
                                                  color: darkCard
                                                      ? const Color.fromARGB(
                                                          255, 220, 220, 220)
                                                      : const Color.fromARGB(
                                                          255, 0, 0, 0)),
                                            ),
                                            Image.network(
                                              'https://openweathermap.org/img/wn/${item.icon}@2x.png',
                                              width: 50,
                                              height: 50,
                                            ),
                                            Text(
                                              '${item.temperature}ºC',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: darkCard
                                                    ? const Color.fromARGB(
                                                        255, 220, 220, 220)
                                                    : const Color.fromARGB(
                                                        255, 0, 0, 0),
                                              ),
                                            ),
                                            Text(
                                              '$rainChance% lluvia',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: darkCard
                                                    ? const Color.fromARGB(
                                                        255, 220, 220, 220)
                                                    : const Color.fromARGB(
                                                        255, 0, 0, 0),
                                              ),
                                            ),
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
