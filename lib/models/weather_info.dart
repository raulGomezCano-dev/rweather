class WeatherInfo {
  final String city;
  final String weatherType;
  final int temperature;
  final int minTemperature;
  final int maxTemperature;
  final int feelsLike;
  final String description;
  final String icon;
  final int humidity;
  final int windSpeed;

  WeatherInfo(
      {required this.city,
      required this.weatherType,
      required this.temperature,
      required this.description,
      required this.icon,
      required this.humidity,
      required this.feelsLike,
      required this.windSpeed,
      required this.minTemperature,
      required this.maxTemperature});

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      city: json['name'],
      weatherType: json['weather'][0]['main'],
      temperature: double.parse(json['main']['temp'].toString()).round(),
      minTemperature: double.parse(json['main']['temp_min'].toString()).round(),
      maxTemperature: double.parse(json['main']['temp_max'].toString()).round(),
      description: json['weather'][0]['description'].toString(),
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      feelsLike: double.parse(json['main']['feels_like'].toString()).round(),
      windSpeed: double.parse(json['wind']['speed'].toString()).round(),
    );
  }
}
