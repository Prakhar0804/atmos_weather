import 'package:flutter/material.dart';
import '../../../../core/utils/weather_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/weather.dart';

/// Large hero card displaying the current weather conditions.
///
/// Shows the temperature prominently (96px font), along with the city name,
/// weather description, feels-like temperature, and current date.
/// All contained within a glassmorphism panel.
class CurrentWeatherCard extends StatelessWidget {
  final Weather weather;

  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // City name
          Text(
            weather.cityName,
            style: textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Date
          Text(
            AppDateUtils.formatFullDate(DateTime.now()),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Weather icon
          Icon(
            WeatherUtils.getIcon(weather.weatherCode, isDay: weather.isDay),
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),

          // Temperature
          Text(
            '${weather.temperature.round()}°',
            style: textTheme.displayLarge,
          ),
          const SizedBox(height: 8),

          // Weather description
          Text(
            WeatherUtils.getDescription(weather.weatherCode),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),

          // Feels like
          Text(
            'Feels like ${weather.apparentTemperature.round()}°',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
