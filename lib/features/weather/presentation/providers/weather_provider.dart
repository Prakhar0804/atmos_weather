import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../domain/entities/weather.dart';

/// Manages weather data state using Riverpod's StateNotifier pattern.
///
/// ### State Flow:
/// ```
/// WeatherInitial → WeatherLoading → WeatherLoaded (or WeatherError)
///                                 ↑ (refresh)     ↓
///                                 └────────────────┘
/// ```
///
/// ### Interview talking point:
/// We use a sealed-class-like pattern with a base [WeatherState] class and
/// subclasses for each state. This makes it easy to handle all possible states
/// in the UI with `if (state is WeatherLoaded)` checks, ensuring we never
/// accidentally show stale data or miss an error state.

// ── Weather State Classes ─────────────────────────────────────────────

/// Base class for all weather states.
abstract class WeatherState {
  const WeatherState();
}

/// Initial state before any data has been requested.
class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

/// Loading state while fetching weather data.
class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

/// Successfully loaded weather data.
class WeatherLoaded extends WeatherState {
  final Weather weather;
  const WeatherLoaded(this.weather);
}

/// Error state when fetching fails.
class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message);
}

// ── Provider ──────────────────────────────────────────────────────────

/// The repository provider — creates a single instance shared across the app.
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final repo = WeatherRepository();
  ref.onDispose(() => repo.dispose());
  return repo;
});

/// The main weather state provider.
final weatherProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);
  return WeatherNotifier(repository);
});

/// Provider for city search results.
/// Uses a family provider so we can pass the search query as a parameter.
final citySearchProvider =
    FutureProvider.family<List<LocationModel>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.searchCity(query);
});

// ── Notifier ──────────────────────────────────────────────────────────

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepository _repository;

  /// Stores the last fetched coordinates for pull-to-refresh.
  double? _lastLatitude;
  double? _lastLongitude;
  String? _lastCityName;

  WeatherNotifier(this._repository) : super(const WeatherInitial());

  /// Fetches weather by city name (used from search).
  Future<void> fetchWeatherByCity(String cityName) async {
    state = const WeatherLoading();
    try {
      final weather = await _repository.getWeatherByCity(cityName);
      _lastLatitude = weather.latitude;
      _lastLongitude = weather.longitude;
      _lastCityName = weather.cityName;
      state = WeatherLoaded(weather);
    } catch (e) {
      state = WeatherError(_getErrorMessage(e));
    }
  }

  /// Fetches weather by coordinates (used from GPS location).
  Future<void> fetchWeatherByCoords(
    double latitude,
    double longitude,
    String cityName,
  ) async {
    state = const WeatherLoading();
    try {
      final weather = await _repository.getWeatherByCoords(
        latitude,
        longitude,
        cityName,
      );
      _lastLatitude = latitude;
      _lastLongitude = longitude;
      _lastCityName = cityName;
      state = WeatherLoaded(weather);
    } catch (e) {
      state = WeatherError(_getErrorMessage(e));
    }
  }

  /// Refreshes the current weather data using the last known location.
  Future<void> refresh() async {
    if (_lastLatitude != null && _lastLongitude != null && _lastCityName != null) {
      // Don't set to loading — keep showing current data during refresh
      try {
        final weather = await _repository.getWeatherByCoords(
          _lastLatitude!,
          _lastLongitude!,
          _lastCityName!,
        );
        state = WeatherLoaded(weather);
      } catch (e) {
        // On refresh failure, keep the old data but we could show a snackbar
        // For now, we silently fail — the old data is still showing
      }
    }
  }

  /// Converts exceptions to user-friendly error messages.
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('not found')) {
      return 'City not found. Please check the spelling.';
    }
    if (error.toString().contains('SocketException') ||
        error.toString().contains('ClientException')) {
      return 'No internet connection. Please check your network.';
    }
    return 'Something went wrong. Please try again.';
  }
}
