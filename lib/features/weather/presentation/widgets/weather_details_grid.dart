import 'package:flutter/material.dart';
import '../../../../core/utils/weather_utils.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/weather.dart';

/// 2×3 grid of glass cards displaying detailed weather metrics.
///
/// Each card shows an icon, label, and value for:
/// - Wind speed & direction
/// - Humidity
/// - UV Index
/// - Pressure
/// - Sunrise
/// - Sunset
class WeatherDetailsGrid extends StatelessWidget {
  final Weather weather;

  const WeatherDetailsGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    // Get sunrise/sunset from today's daily forecast (if available)
    String sunrise = '--';
    String sunset = '--';
    if (weather.dailyForecast.isNotEmpty) {
      final today = weather.dailyForecast.first;
      sunrise =
          '${today.sunrise.hour.toString().padLeft(2, '0')}:${today.sunrise.minute.toString().padLeft(2, '0')}';
      sunset =
          '${today.sunset.hour.toString().padLeft(2, '0')}:${today.sunset.minute.toString().padLeft(2, '0')}';
    }

    final details = [
      _DetailItem(
        icon: Icons.air_rounded,
        label: 'Wind',
        value: '${weather.windSpeed.round()} km/h',
        subtitle: WeatherUtils.getWindDirection(weather.windDirection),
      ),
      _DetailItem(
        icon: Icons.water_drop_outlined,
        label: 'Humidity',
        value: '${weather.humidity.round()}%',
      ),
      _DetailItem(
        icon: Icons.wb_sunny_outlined,
        label: 'UV Index',
        value: weather.uvIndex.toStringAsFixed(1),
        subtitle: _getUvLabel(weather.uvIndex),
      ),
      _DetailItem(
        icon: Icons.compress_rounded,
        label: 'Pressure',
        value: '${weather.pressure.round()} hPa',
      ),
      _DetailItem(
        icon: Icons.wb_twilight_rounded,
        label: 'Sunrise',
        value: sunrise,
      ),
      _DetailItem(
        icon: Icons.nights_stay_outlined,
        label: 'Sunset',
        value: sunset,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        return _DetailCard(item: details[index]);
      },
    );
  }

  static String _getUvLabel(double uv) {
    if (uv <= 2) return 'Low';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High';
    if (uv <= 10) return 'Very High';
    return 'Extreme';
  }
}

/// Internal data class for a single detail item.
class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });
}

/// Glass card displaying a single weather detail.
class _DetailCard extends StatelessWidget {
  final _DetailItem item;

  const _DetailCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: textTheme.headlineMedium,
          ),
          if (item.subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              item.subtitle!,
              style: textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}
