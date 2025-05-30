import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rweather/models/hourly_weather.dart';
import 'package:rweather/models/weather_info.dart';
import 'package:rweather/screens/city_searcher.dart';
import 'package:rweather/screens/start.dart';
import 'package:rweather/services/background_image_service.dart';
import 'package:rweather/services/city_search_service.dart';
import 'package:rweather/services/internet_connection_service.dart';
import 'package:rweather/services/weather_service.dart';
import 'package:rweather/widgets/internet_connection_snackbar.dart';

class HomeScreen extends StatefulWidget {
  final String city;
  const HomeScreen({super.key, required this.city});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool isConnected = true;
  late final InternetConnectionService _connectionService;
  final weatherService = WeatherService();
  final backgroundImageService = BackgroundImageService();
  final cityService = CitySearchService();
  final TextEditingController cityController = TextEditingController();

  String lat = '';
  String lon = '';
  late String city;
  int temperature = 0;
  int feelsLike = 0;
  String description = '';
  int windSpeed = 0;
  WeatherInfo? weatherData;
  List<HourlyWeather> hourlyForecast = [];
  String? backgroundImageUrl;
  String? localTime;
  bool searchingCity = false;
  bool lightCard = false;

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
    city = widget.city;
    initializeWeather(); // Método auxiliar, ya que no se puede usar async dentro de initState
  }

  @override
  void dispose() {
    _connectionService.dispose();
    super.dispose();
  }

  Future<void> initializeWeather() async {
    await setCoordinates(city);
    await loadWeather();
    await loadHourlyForecast();
  }

  Future<void> setCoordinates(String city) async {
    final coords = await cityService.getCoordinates(city);
    setState(() {
      lat = coords['lat'].toString();
      lon = coords['lng'].toString();
    });
  }

  Future<void> loadWeather() async {
    try {
      final data = await weatherService.fetchCurrentWeather(lat, lon);
      setState(() {
        weatherData = data;
        temperature = weatherData!.temperature;
        description = weatherData!.description;
        feelsLike = weatherData!.feelsLike;
        windSpeed = weatherData!.windSpeed;
        localTime = weatherData!.localTime;
        loadBackgroundImage(
            weatherData!.weatherType); // Cambiar el fondo según el clima
        // Cambiar el color de Cards y sus Text dependiendo del fondo
        if (weatherData!.weatherType == 'Thunderstorm' ||
            weatherData!.weatherType == 'Drizzle') {
          lightCard = true;
        } else {
          lightCard = false;
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
    return Scaffold(
      body: weatherData == null || backgroundImageUrl == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (isConnected) {
                  await loadWeather();
                  await loadHourlyForecast();
                  setState(() {
                    searchingCity = false;
                  });
                } else {
                  InternetConnectionSnackbar.show(context, isConnected);
                }
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
                              color: const Color.fromARGB(255, 0, 0, 0)
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
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: BackButton(
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const StartScreen()),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                    color: lightCard
                                        ? const Color.fromARGB(
                                                255, 220, 220, 220)
                                        : const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final selectedCity =
                                          await Navigator.push<String>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CitySearcher(
                                                  fromStart: false),
                                        ),
                                      );

                                      if (selectedCity != null &&
                                          selectedCity.isNotEmpty) {
                                        setState(() {
                                          city = selectedCity;
                                        });
                                        await initializeWeather();
                                      }
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
                                        Icon(Icons.search,
                                            color: Colors.white70),
                                        SizedBox(width: 8),
                                        Text('Buscar ciudad',
                                            style: TextStyle(
                                                color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(
                          height: 40,
                        ),
                        Image.network(
                          'https://openweathermap.org/img/wn/${weatherData!.icon}@2x.png',
                          width: 100,
                          height: 100,
                        ),
                        Text(
                          weatherData!.description,
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          city,
                          style: const TextStyle(fontSize: 18),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.wind_power),
                                Text(
                                  '$windSpeed m/s',
                                  style: const TextStyle(fontSize: 16),
                                ),
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
                                Text(
                                  'Sensación de $feelsLikeºC',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.access_time),
                                Text(
                                  localTime!,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 100,
                        ),
                        hourlyForecast.isEmpty
                            ? const Text('Fallo en predicción')
                            : SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: hourlyForecast.length,
                                  itemBuilder: (context, index) {
                                    final item = hourlyForecast[index];
                                    final day = DateFormat('EEEE d', 'es_ES')
                                        .format(item.dateTime);

                                    final hour = DateFormat('HH:mm')
                                        .format(item.dateTime);

                                    final rainChance = (item.probOfRain * 100)
                                        .toStringAsFixed(0);

                                    return SizedBox(
                                      width: 120,
                                      child: Card(
                                        color: lightCard
                                            ? const Color.fromARGB(
                                                    255, 220, 220, 220)
                                                .withAlpha(80)
                                            : const Color.fromARGB(255, 0, 0, 0)
                                                .withAlpha(30),
                                        margin: const EdgeInsets.all(8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                day,
                                                style: TextStyle(
                                                    color: lightCard
                                                        ? const Color.fromARGB(
                                                            255, 0, 0, 0)
                                                        : const Color.fromARGB(
                                                            255,
                                                            220,
                                                            220,
                                                            220)),
                                              ),
                                              Text(
                                                hour,
                                                style: TextStyle(
                                                    color: lightCard
                                                        ? const Color.fromARGB(
                                                            255, 0, 0, 0)
                                                        : const Color.fromARGB(
                                                            255,
                                                            220,
                                                            220,
                                                            220)),
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
                                                  fontSize: 20,
                                                  color: lightCard
                                                      ? const Color.fromARGB(
                                                          255, 0, 0, 0)
                                                      : const Color.fromARGB(
                                                          255, 220, 220, 220),
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.water_drop,
                                                      color: lightCard
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 0, 0, 0)
                                                          : const Color
                                                              .fromARGB(255,
                                                              220, 220, 220),
                                                      size: 20,
                                                    ),
                                                    Text(
                                                      '$rainChance%',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: lightCard
                                                            ? const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0)
                                                            : const Color
                                                                .fromARGB(255,
                                                                220, 220, 220),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
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
