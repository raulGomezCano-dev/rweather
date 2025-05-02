import 'package:flutter/material.dart';
import 'package:rweather/models/hourly_weather.dart';
import 'package:rweather/models/weather_info.dart';
import 'package:rweather/services/background_image_service.dart';
import 'package:rweather/services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final weatherService = WeatherService();
  final backgroundImageService = BackgroundImageService();

  double temperature = 0;
  double minTemperature = 0;
  double maxTemperature = 0;
  double feelsLike = 0;
  String description = '';
  double windSpeed = 0;
  WeatherInfo? weatherData;
  List<HourlyWeather> hourlyForecast = [];

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
        description = weatherData!.description;
        feelsLike = weatherData!.feelsLike;
        windSpeed = weatherData!.windSpeed;
      });
    } catch (e) {
      print(e);
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
    // String weatherType = weatherData?.weatherType ??
    //     'Clear'; // Por defecto 'Clear' si no se obtiene
    // String backgroundImageUrl = backgroundImageService.getImageUrl(weatherType);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        ],
      ),
      body: weatherData == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                // image: DecorationImage(
                //   image: NetworkImage(backgroundImageUrl),
                //   fit: BoxFit.cover,
                // ),
                color: const Color.fromARGB(255, 9, 120, 135).withAlpha(55),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Ayer')),
                      TextButton(onPressed: () {}, child: const Text('Hoy')),
                      TextButton(onPressed: () {}, child: const Text('Mañana'))
                    ],
                  ),
                  Image.network(
                    'https://openweathermap.org/img/wn/${weatherData!.icon}@2x.png',
                    width: 100,
                    height: 100,
                  ),
                  Text(weatherData!.description),
                  const Text('Madrid'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Viento
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wind_power),
                          Text('$windSpeed m/s')
                        ],
                      ),
                      // Temperatura
                      Column(
                        children: [
                          Text('$temperatureºC'),
                          Text('Sensación de $feelsLikeºC')
                        ],
                      ),
                      // Minimo/Maximo
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
                              final hour = TimeOfDay.fromDateTime(item.dateTime)
                                  .format(context);
                              final rainChance =
                                  (item.probOfRain * 100).toStringAsFixed(0);

                              return Card(
                                margin: const EdgeInsets.all(8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                ],
              ),
            ),
    );
  }
}
