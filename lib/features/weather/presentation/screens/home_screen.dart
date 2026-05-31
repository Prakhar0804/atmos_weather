import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/dynamic_background.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/weather_details_grid.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/air_quality_card.dart';
import 'search_screen.dart';
import 'saved_cities_screen.dart';

/// Main weather dashboard screen.
///
/// Displays the current weather, hourly forecast, 7-day forecast,
/// weather details, and air quality — all on top of a dynamic gradient
/// background that changes with weather conditions.
///
/// ### Features:
/// - Auto-detects GPS location on first launch
/// - Pull-to-refresh for weather data
/// - Navigation to city search and saved cities
/// - Dark/light theme toggle
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch weather on first load using GPS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocationWeather();
    });
  }

  /// Attempts to get the user's GPS location and fetch weather.
  /// Falls back to a default city (New Delhi) if location is unavailable.
  Future<void> _fetchLocationWeather() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _fetchDefaultCity();
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _fetchDefaultCity();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _fetchDefaultCity();
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Fetch weather for current location
      ref.read(weatherProvider.notifier).fetchWeatherByCoords(
            position.latitude,
            position.longitude,
            'Current Location',
          );
    } catch (e) {
      _fetchDefaultCity();
    }
  }

  /// Fallback: fetch weather for New Delhi if GPS fails.
  void _fetchDefaultCity() {
    ref.read(weatherProvider.notifier).fetchWeatherByCity('New Delhi');
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _buildBody(weatherState, isDarkMode),
    );
  }

  Widget _buildBody(WeatherState weatherState, bool isDarkMode) {
    // ── Loading State ──
    if (weatherState is WeatherLoading || weatherState is WeatherInitial) {
      return const DefaultBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Fetching weather...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // ── Error State ──
    if (weatherState is WeatherError) {
      return DefaultBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 80, color: Colors.white54),
                const SizedBox(height: 16),
                Text(
                  weatherState.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _fetchLocationWeather,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Loaded State ──
    final weather = (weatherState as WeatherLoaded).weather;

    return DynamicBackground(
      weatherCode: weather.weatherCode,
      isDay: weather.isDay,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(weatherProvider.notifier).refresh(),
          color: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── App Bar ──
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                  onPressed: () => _openSavedCities(context),
                  tooltip: 'Saved Cities',
                ),
                actions: [
                  // Theme toggle
                  IconButton(
                    icon: Icon(
                      isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        ref.read(themeProvider.notifier).toggleTheme(),
                    tooltip: 'Toggle Theme',
                  ),
                  // Search
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Colors.white),
                    onPressed: () => _openSearch(context),
                    tooltip: 'Search City',
                  ),
                ],
              ),

              // ── Content ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // Current weather hero card
                    CurrentWeatherCard(weather: weather),
                    const SizedBox(height: 20),

                    // Hourly forecast
                    HourlyForecastList(forecasts: weather.hourlyForecast),
                    const SizedBox(height: 20),

                    // 7-day forecast
                    DailyForecastList(forecasts: weather.dailyForecast),
                    const SizedBox(height: 20),

                    // Weather details grid
                    WeatherDetailsGrid(weather: weather),
                    const SizedBox(height: 20),

                    // Air Quality (only if data is available)
                    if (weather.aqi != null)
                      AirQualityCard(
                        aqi: weather.aqi!,
                        pm25: weather.pm25,
                        pm10: weather.pm10,
                      ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the search screen and fetches weather if a city is selected.
  Future<void> _openSearch(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      ref.read(weatherProvider.notifier).fetchWeatherByCoords(
            result['latitude'],
            result['longitude'],
            result['name'],
          );
    }
  }

  /// Opens the saved cities screen.
  Future<void> _openSavedCities(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedCitiesScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      ref.read(weatherProvider.notifier).fetchWeatherByCoords(
            result['latitude'],
            result['longitude'],
            result['name'],
          );
    }
  }
}
