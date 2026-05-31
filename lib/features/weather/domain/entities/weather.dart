/// Core weather entity representing current weather conditions.
///
/// This is a clean domain entity — it has no dependency on any specific API
/// or JSON format. The data layer's [WeatherModel] converts API responses
/// into this entity, keeping our business logic decoupled from the API.
class Weather {
  final String cityName;
  final double latitude;
  final double longitude;
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final double humidity;
  final double windSpeed;
  final double windDirection;
  final double pressure;
  final double uvIndex;
  final bool isDay;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final int? aqi;
  final double? pm25;
  final double? pm10;

  const Weather({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.uvIndex,
    required this.isDay,
    required this.hourlyForecast,
    required this.dailyForecast,
    this.aqi,
    this.pm25,
    this.pm10,
  });

  /// Creates a copy of this entity with some fields replaced.
  /// Useful for adding AQI data after the initial weather fetch.
  Weather copyWith({
    String? cityName,
    double? latitude,
    double? longitude,
    double? temperature,
    double? apparentTemperature,
    int? weatherCode,
    double? humidity,
    double? windSpeed,
    double? windDirection,
    double? pressure,
    double? uvIndex,
    bool? isDay,
    List<HourlyForecast>? hourlyForecast,
    List<DailyForecast>? dailyForecast,
    int? aqi,
    double? pm25,
    double? pm10,
  }) {
    return Weather(
      cityName: cityName ?? this.cityName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temperature: temperature ?? this.temperature,
      apparentTemperature: apparentTemperature ?? this.apparentTemperature,
      weatherCode: weatherCode ?? this.weatherCode,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      pressure: pressure ?? this.pressure,
      uvIndex: uvIndex ?? this.uvIndex,
      isDay: isDay ?? this.isDay,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      aqi: aqi ?? this.aqi,
      pm25: pm25 ?? this.pm25,
      pm10: pm10 ?? this.pm10,
    );
  }
}

/// Represents a single hour's forecast data.
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;
  final bool isDay;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.isDay,
  });
}

/// Represents a single day's forecast data.
class DailyForecast {
  final DateTime date;
  final double temperatureMax;
  final double temperatureMin;
  final int weatherCode;
  final int precipitationProbabilityMax;
  final DateTime sunrise;
  final DateTime sunset;

  const DailyForecast({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.weatherCode,
    required this.precipitationProbabilityMax,
    required this.sunrise,
    required this.sunset,
  });
}
