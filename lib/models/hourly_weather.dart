class HourlyWeather {
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final String icon;
  final double probOfRain;
  final DateTime dateTime;

  HourlyWeather({
    required this.temperature,
    required this.icon,
    required this.minTemperature,
    required this.maxTemperature,
    required this.probOfRain,
    required this.dateTime
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      temperature: json['main']['temp'],
      minTemperature: json['main']['temp_min'],
      maxTemperature: json['main']['temp_max'],
      icon: json['weather'][0]['icon'],
      probOfRain: (json['pop'] ?? 0).toDouble(),
      dateTime: DateTime.parse(json['dt_txt']),
    );
  }
}
