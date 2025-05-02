class BackgroundImageService {
  String getImageUrl(String weatherType) {
    switch (weatherType) {
      case 'Clear':
        return 'https://source.unsplash.com/1600x900/?clear-sky';
      case 'Clouds':
        return 'https://source.unsplash.com/1600x900/?clouds';
      case 'Rain':
        return 'https://source.unsplash.com/1600x900/?rainy';
      case 'Snow':
        return 'https://source.unsplash.com/1600x900/?snow';
      case 'Thunderstorm':
        return 'https://source.unsplash.com/1600x900/?thunderstorm';
      case 'Drizzle':
        return 'https://source.unsplash.com/1600x900/?drizzle';
      case 'Mist':
        return 'https://source.unsplash.com/1600x900/?mist';
      case 'Smoke':
        return 'https://source.unsplash.com/1600x900/?smoke';
      case 'Haze':
        return 'https://source.unsplash.com/1600x900/?haze';
      case 'Dust':
        return 'https://source.unsplash.com/1600x900/?dust';
      case 'Fog':
        return 'https://source.unsplash.com/1600x900/?fog';
      default:
        return 'https://source.unsplash.com/1600x900/?weather';
    }
  }
}