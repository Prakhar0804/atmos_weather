import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

/// Low-level HTTP client for the Open-Meteo API.
///
/// This datasource handles raw HTTP communication only. It doesn't know
/// about our domain entities — that transformation happens in the repository.
///
/// ### Endpoints used:
/// - **Forecast**: `api.open-meteo.com/v1/forecast` — current + hourly + daily
/// - **Geocoding**: `geocoding-api.open-meteo.com/v1/search` — city lookup
/// - **Air Quality**: `air-quality-api.open-meteo.com/v1/air-quality` — AQI data
class WeatherApiClient {
  final http.Client _client;

  WeatherApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches weather data for given coordinates.
  ///
  /// Returns the decoded JSON map from the Forecast API.
  /// Throws [WeatherApiException] on HTTP errors.
  Future<Map<String, dynamic>> fetchWeather(
    double latitude,
    double longitude,
  ) async {
    final uri = ApiConstants.weatherUri(latitude, longitude);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw WeatherApiException(
        'Failed to fetch weather data',
        statusCode: response.statusCode,
      );
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  /// Searches for cities matching the given query.
  ///
  /// Returns a list of location JSON maps from the Geocoding API.
  /// Returns an empty list if no results are found.
  Future<List<Map<String, dynamic>>> searchCity(String query) async {
    if (query.trim().length < 2) return [];

    final uri = ApiConstants.geocodingUri(query);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw WeatherApiException(
        'Failed to search for city',
        statusCode: response.statusCode,
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;

    // The API returns { "results": [...] } or just {} if no results
    if (!data.containsKey('results')) return [];

    return (data['results'] as List)
        .cast<Map<String, dynamic>>();
  }

  /// Fetches air quality data for given coordinates.
  ///
  /// Returns the decoded JSON map from the Air Quality API.
  Future<Map<String, dynamic>> fetchAirQuality(
    double latitude,
    double longitude,
  ) async {
    final uri = ApiConstants.airQualityUri(latitude, longitude);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw WeatherApiException(
        'Failed to fetch air quality data',
        statusCode: response.statusCode,
      );
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  /// Closes the HTTP client to free resources.
  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors, providing status code context.
class WeatherApiException implements Exception {
  final String message;
  final int? statusCode;

  WeatherApiException(this.message, {this.statusCode});

  @override
  String toString() => 'WeatherApiException: $message (HTTP $statusCode)';
}
