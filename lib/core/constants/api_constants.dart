/// Centralized API constants for the Open-Meteo weather service.
///
/// Open-Meteo is a free, open-source weather API that requires no API key.
/// We use three endpoints: Forecast, Geocoding, and Air Quality.
class ApiConstants {
  ApiConstants._(); // Prevent instantiation

  // ── Base URLs ─────────────────────────────────────────────────────────
  static const String weatherBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String airQualityBaseUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  // ── Current Weather Parameters ────────────────────────────────────────
  /// Comma-separated list of variables to fetch for current conditions.
  static const String currentParams = 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure,uv_index';

  // ── Hourly Forecast Parameters ────────────────────────────────────────
  static const String hourlyParams = 'temperature_2m,weather_code,precipitation_probability,is_day';

  // ── Daily Forecast Parameters ─────────────────────────────────────────
  static const String dailyParams = 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset';

  // ── Air Quality Parameters ────────────────────────────────────────────
  static const String aqiParams = 'us_aqi,pm2_5,pm10';

  // ── Forecast Configuration ────────────────────────────────────────────
  static const int forecastDays = 7;
  static const int geocodingResultCount = 8;

  /// Builds the full weather forecast URL for given coordinates.
  static Uri weatherUri(double latitude, double longitude) {
    return Uri.parse(weatherBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': currentParams,
        'hourly': hourlyParams,
        'daily': dailyParams,
        'timezone': 'auto',
        'forecast_days': forecastDays.toString(),
      },
    );
  }

  /// Builds the geocoding search URL for a city name query.
  static Uri geocodingUri(String query) {
    return Uri.parse(geocodingBaseUrl).replace(
      queryParameters: {
        'name': query,
        'count': geocodingResultCount.toString(),
        'language': 'en',
        'format': 'json',
      },
    );
  }

  /// Builds the air quality URL for given coordinates.
  static Uri airQualityUri(double latitude, double longitude) {
    return Uri.parse(airQualityBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': aqiParams,
      },
    );
  }
}
