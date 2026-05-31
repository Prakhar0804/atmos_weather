import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/weather_utils.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/weather.dart';

/// Vertical list showing the 7-day weather forecast.
///
/// Each row displays the day name, weather icon, a visual temperature
/// range bar, and the min/max temperatures. The bar's position and width
/// are relative to the overall min/max across all 7 days, giving a
/// visual comparison of daily temperature ranges.
class DailyForecastList extends StatelessWidget {
  final List<DailyForecast> forecasts;

  const DailyForecastList({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Calculate the global min and max for the temperature bar scaling.
    double globalMin = double.infinity;
    double globalMax = double.negativeInfinity;
    for (final f in forecasts) {
      if (f.temperatureMin < globalMin) globalMin = f.temperatureMin;
      if (f.temperatureMax > globalMax) globalMax = f.temperatureMax;
    }

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Text('7-Day Forecast', style: textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 12),

          // Daily rows
          ...forecasts.map((forecast) {
            return _DailyRow(
              forecast: forecast,
              globalMin: globalMin,
              globalMax: globalMax,
            );
          }),
        ],
      ),
    );
  }
}

/// A single day's forecast row.
class _DailyRow extends StatelessWidget {
  final DailyForecast forecast;
  final double globalMin;
  final double globalMax;

  const _DailyRow({
    required this.forecast,
    required this.globalMin,
    required this.globalMax,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final range = globalMax - globalMin;

    // Calculate bar position as a fraction of the global range
    final barStart = range > 0 ? (forecast.temperatureMin - globalMin) / range : 0.0;
    final barEnd = range > 0 ? (forecast.temperatureMax - globalMin) / range : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Day name (fixed width for alignment)
          SizedBox(
            width: 48,
            child: Text(
              AppDateUtils.formatDayLabel(forecast.date),
              style: textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: 8),

          // Weather icon
          Icon(
            WeatherUtils.getIcon(forecast.weatherCode),
            size: 24,
            color: Colors.white,
          ),
          const SizedBox(width: 8),

          // Precipitation probability (if significant)
          SizedBox(
            width: 36,
            child: forecast.precipitationProbabilityMax > 10
                ? Text(
                    '${forecast.precipitationProbabilityMax}%',
                    style: textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF64B5F6),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Min temperature
          SizedBox(
            width: 32,
            child: Text(
              '${forecast.temperatureMin.round()}°',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),

          // Temperature range bar
          Expanded(
            child: _TemperatureBar(
              barStart: barStart,
              barEnd: barEnd,
            ),
          ),
          const SizedBox(width: 8),

          // Max temperature
          SizedBox(
            width: 32,
            child: Text(
              '${forecast.temperatureMax.round()}°',
              style: textTheme.labelLarge,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual temperature range bar with gradient coloring.
class _TemperatureBar extends StatelessWidget {
  final double barStart;
  final double barEnd;

  const _TemperatureBar({
    required this.barStart,
    required this.barEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final leftPadding = totalWidth * barStart;
        final barWidth = totalWidth * (barEnd - barStart);

        return SizedBox(
          height: 6,
          child: Stack(
            children: [
              // Background track
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Active bar with gradient
              Positioned(
                left: leftPadding,
                child: Container(
                  width: barWidth.clamp(8.0, totalWidth),
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF64B5F6), // Cool blue
                        Color(0xFFFFA726), // Warm orange
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
