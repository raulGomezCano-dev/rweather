class HourlyWeather {
  final int temperature;
  final int minTemperature;
  final int maxTemperature;
  final String icon;
  final double probOfRain;
  final DateTime dateTime;

  HourlyWeather(
      {required this.temperature,
      required this.icon,
      required this.minTemperature,
      required this.maxTemperature,
      required this.probOfRain,
      required this.dateTime});

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      temperature: (json['main']['temp'] as num).round(),
      minTemperature: (json['main']['temp_min'] as num).round(),
      maxTemperature: (json['main']['temp_max'] as num).round(),
      icon: json['weather'][0]['icon'],
      probOfRain: (json['pop'] ?? 0).toDouble(),
      dateTime: DateTime.parse(json['dt_txt']),
    );
  }
}
