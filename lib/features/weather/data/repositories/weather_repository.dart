import '../datasources/weather_api_client.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';
import '../../domain/entities/weather.dart';

/// Repository that orchestrates API calls and transforms raw data
/// into clean domain entities.
///
/// This is the single source of truth for weather data in the app.
/// The presentation layer (providers) only interacts with this repository,
/// never directly with the API client.
///
/// ### Responsibilities:
/// 1. Coordinate weather + AQI API calls
/// 2. Transform API JSON → Domain entities
/// 3. Handle errors gracefully
class WeatherRepository {
  final WeatherApiClient _apiClient;

  WeatherRepository({WeatherApiClient? apiClient})
      : _apiClient = apiClient ?? WeatherApiClient();

  /// Fetches complete weather data (including AQI) for a city name.
  ///
  /// Flow: Search city → Get coordinates → Fetch weather + AQI → Combine
  Future<Weather> getWeatherByCity(String cityName) async {
    // Step 1: Search for the city to get coordinates
    final locations = await searchCity(cityName);
    if (locations.isEmpty) {
      throw WeatherApiException('City "$cityName" not found');
    }

    final location = locations.first;
    return getWeatherByCoords(
      location.latitude,
      location.longitude,
      location.name,
    );
  }

  /// Fetches complete weather data for given coordinates.
  ///
  /// Makes parallel API calls for weather and AQI data for better performance.
  Future<Weather> getWeatherByCoords(
    double latitude,
    double longitude,
    String cityName,
  ) async {
    // Fetch weather and AQI in parallel for better performance
    final results = await Future.wait([
      _apiClient.fetchWeather(latitude, longitude),
      _apiClient.fetchAirQuality(latitude, longitude).catchError((_) => <String, dynamic>{}),
    ]);

    final weatherJson = results[0];
    final aqiJson = results[1];

    // Parse weather data
    Weather weather = WeatherModel.fromJson(weatherJson, cityName);

    // Add AQI data if available
    if (aqiJson.containsKey('current')) {
      final aqiCurrent = aqiJson['current'] as Map<String, dynamic>;
      weather = weather.copyWith(
        aqi: (aqiCurrent['us_aqi'] as num?)?.toInt(),
        pm25: (aqiCurrent['pm2_5'] as num?)?.toDouble(),
        pm10: (aqiCurrent['pm10'] as num?)?.toDouble(),
      );
    }

    return weather;
  }

  /// Searches for cities matching the query string.
  ///
  /// Returns a list of [LocationModel] for the autocomplete UI.
  Future<List<LocationModel>> searchCity(String query) async {
    final results = await _apiClient.searchCity(query);
    return results.map((json) => LocationModel.fromJson(json)).toList();
  }

  /// Closes the underlying HTTP client.
  void dispose() {
    _apiClient.dispose();
  }
}
