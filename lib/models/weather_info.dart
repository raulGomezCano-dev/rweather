class WeatherInfo {
  final String city;
  final String weatherType;
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final double feelsLike;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  WeatherInfo({
    required this.city,
    required this.weatherType,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.feelsLike,
    required this.windSpeed,
    required this.minTemperature,
    required this.maxTemperature
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      city: json['name'],
      weatherType: json['weather'][0]['main'],
      temperature: json['main']['temp'],
      minTemperature: json['main']['temp_min'],
      maxTemperature: json['main']['temp_max'],
      description: json['weather'][0]['description'].toString(),
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      feelsLike: json['main']['feels_like'],
      windSpeed: json['wind']['speed']
    );
  }
}
