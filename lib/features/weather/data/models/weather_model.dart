import '../../domain/entities/weather.dart';

/// Model class responsible for parsing the Open-Meteo Forecast API response.
///
/// The API returns a JSON structure with `current`, `hourly`, and `daily`
/// objects. This model transforms that raw JSON into our clean [Weather] entity.
///
/// ### API Response Structure (simplified):
/// ```json
/// {
///   "current": { "temperature_2m": 22.3, "weather_code": 0, ... },
///   "hourly": { "time": [...], "temperature_2m": [...], ... },
///   "daily": { "time": [...], "temperature_2m_max": [...], ... }
/// }
/// ```
class WeatherModel {
  /// Converts the full API response JSON into a [Weather] domain entity.
  ///
  /// [json] is the decoded response from Open-Meteo forecast endpoint.
  /// [cityName] is provided separately (from geocoding or user input).
  static Weather fromJson(Map<String, dynamic> json, String cityName) {
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    return Weather(
      cityName: cityName,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      humidity: (current['relative_humidity_2m'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDirection: (current['wind_direction_10m'] as num).toDouble(),
      pressure: (current['surface_pressure'] as num).toDouble(),
      uvIndex: (current['uv_index'] as num).toDouble(),
      isDay: (current['is_day'] as num).toInt() == 1,
      hourlyForecast: _parseHourly(hourly),
      dailyForecast: _parseDaily(daily),
    );
  }

  /// Parses the `hourly` section into a list of [HourlyForecast] entities.
  /// We take only the next 24 hours to keep the UI clean.
  static List<HourlyForecast> _parseHourly(Map<String, dynamic> hourly) {
    final times = (hourly['time'] as List).cast<String>();
    final temps = (hourly['temperature_2m'] as List).cast<num>();
    final codes = (hourly['weather_code'] as List).cast<num>();
    final precip = (hourly['precipitation_probability'] as List).cast<num>();
    final isDay = (hourly['is_day'] as List).cast<num>();

    final now = DateTime.now();
    final List<HourlyForecast> forecasts = [];

    for (int i = 0; i < times.length && forecasts.length < 24; i++) {
      final time = DateTime.parse(times[i]);
      // Only include future hours
      if (time.isAfter(now.subtract(const Duration(hours: 1)))) {
        forecasts.add(HourlyForecast(
          time: time,
          temperature: temps[i].toDouble(),
          weatherCode: codes[i].toInt(),
          precipitationProbability: precip[i].toInt(),
          isDay: isDay[i].toInt() == 1,
        ));
      }
    }

    return forecasts;
  }

  /// Parses the `daily` section into a list of [DailyForecast] entities.
  static List<DailyForecast> _parseDaily(Map<String, dynamic> daily) {
    final times = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List).cast<num>();
    final codes = (daily['weather_code'] as List).cast<num>();
    final precip = (daily['precipitation_probability_max'] as List).cast<num>();
    final sunrises = (daily['sunrise'] as List).cast<String>();
    final sunsets = (daily['sunset'] as List).cast<String>();

    return List.generate(times.length, (i) {
      return DailyForecast(
        date: DateTime.parse(times[i]),
        temperatureMax: maxTemps[i].toDouble(),
        temperatureMin: minTemps[i].toDouble(),
        weatherCode: codes[i].toInt(),
        precipitationProbabilityMax: precip[i].toInt(),
        sunrise: DateTime.parse(sunrises[i]),
        sunset: DateTime.parse(sunsets[i]),
      );
    });
  }
}
