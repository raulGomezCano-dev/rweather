import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rweather/models/hourly_weather.dart';
import 'package:rweather/models/weather_info.dart';

class WeatherService {
  final String lat = '40.4531';
  final String lon = '-3.6883';
  final String apiKey = 'f1e2ea0a33edd83daff1f8fdddddae11';

  Future<WeatherInfo> fetchCurrentWeather() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherInfo.fromJson(data);
    } else {
      throw Exception('Error al obtener el clima actual');
    }
  }

  Future<List<HourlyWeather>> fetchHourlyForecast() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> forecastList = data['list'];
      return forecastList.map((item) => HourlyWeather.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener la previsión');
    }
  }
}
