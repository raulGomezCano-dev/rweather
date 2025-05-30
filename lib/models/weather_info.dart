import 'package:intl/intl.dart';

class WeatherInfo {
  final String city;
  final String weatherType;
  final int temperature;
  final int feelsLike;
  final String description;
  final String icon;
  final int humidity;
  final int windSpeed;
  final String localTime;

  WeatherInfo(
      {required this.city,
      required this.weatherType,
      required this.temperature,
      required this.description,
      required this.icon,
      required this.humidity,
      required this.feelsLike,
      required this.windSpeed,
      required this.localTime});

  // Función para poner la primera letra en mayúscula
  static String capitalize(String text) =>
      text[0].toUpperCase() + text.substring(1);

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    int timezoneOffset = json['timezone'];
    DateTime now =
        DateTime.now().toUtc().add(Duration(seconds: timezoneOffset));
    String formattedTime = DateFormat('HH:mm', 'es_ES').format(now);

    return WeatherInfo(
        city: json['name'],
        weatherType: json['weather'][0]['main'],
        temperature: double.parse(json['main']['temp'].toString()).round(),
        description: capitalize(json['weather'][0]['description'].toString()),
        icon: json['weather'][0]['icon'],
        humidity: json['main']['humidity'],
        feelsLike: double.parse(json['main']['feels_like'].toString()).round(),
        windSpeed: double.parse(json['wind']['speed'].toString()).round(),
        localTime: formattedTime);
  }
}
