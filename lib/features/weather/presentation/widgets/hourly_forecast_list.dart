import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/weather_utils.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/weather.dart';

/// Horizontal scrolling list showing the next 24 hours of weather.
///
/// Each item displays the time, weather icon, and temperature in a
/// compact glass card. The list is wrapped in a larger glass container
/// with a "Hourly Forecast" header.
class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecast> forecasts;

  const HourlyForecastList({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Text('Hourly Forecast', style: textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal scrolling list
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: forecasts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _HourlyItem(forecast: forecasts[index], isFirst: index == 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A single hourly forecast item.
class _HourlyItem extends StatelessWidget {
  final HourlyForecast forecast;
  final bool isFirst;

  const _HourlyItem({required this.forecast, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isFirst
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: isFirst
            ? Border.all(color: Colors.white.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time label — "Now" for the first item
          Text(
            isFirst ? 'Now' : AppDateUtils.formatHour(forecast.time),
            style: textTheme.labelMedium?.copyWith(
              fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
            ),
          ),

          // Weather icon
          Icon(
            WeatherUtils.getIcon(forecast.weatherCode, isDay: forecast.isDay),
            size: 28,
            color: Colors.white,
          ),

          // Temperature
          Text(
            '${forecast.temperature.round()}°',
            style: textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
