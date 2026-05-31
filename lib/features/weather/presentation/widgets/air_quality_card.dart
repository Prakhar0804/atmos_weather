import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

/// Air Quality Index (AQI) display card.
///
/// Shows the US AQI value with a color-coded indicator, a label
/// (Good, Moderate, Unhealthy, etc.), and PM2.5/PM10 values.
class AirQualityCard extends StatelessWidget {
  final int aqi;
  final double? pm25;
  final double? pm10;

  const AirQualityCard({
    super.key,
    required this.aqi,
    this.pm25,
    this.pm10,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final aqiColor = AppColors.getAqiColor(aqi);
    final aqiLabel = AppColors.getAqiLabel(aqi);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Icon(Icons.eco_rounded, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Text('Air Quality', style: textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),

          // AQI value and label
          Row(
            children: [
              // Colored AQI circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: aqiColor.withValues(alpha: 0.2),
                  border: Border.all(color: aqiColor, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    '$aqi',
                    style: textTheme.headlineMedium?.copyWith(
                      color: aqiColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Label and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aqiLabel,
                      style: textTheme.labelLarge?.copyWith(
                        color: aqiColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'US AQI',
                      style: textTheme.labelSmall,
                    ),
                  ],
                ),
              ),

              // PM values
              if (pm25 != null || pm10 != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (pm25 != null)
                      Text(
                        'PM2.5: ${pm25!.toStringAsFixed(1)}',
                        style: textTheme.labelSmall,
                      ),
                    if (pm10 != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'PM10: ${pm10!.toStringAsFixed(1)}',
                        style: textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // AQI color scale bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  _ScaleSegment(color: AppColors.aqiGood, flex: 50),
                  _ScaleSegment(color: AppColors.aqiModerate, flex: 50),
                  _ScaleSegment(color: AppColors.aqiUnhealthySensitive, flex: 50),
                  _ScaleSegment(color: AppColors.aqiUnhealthy, flex: 50),
                  _ScaleSegment(color: AppColors.aqiVeryUnhealthy, flex: 100),
                  _ScaleSegment(color: AppColors.aqiHazardous, flex: 200),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleSegment extends StatelessWidget {
  final Color color;
  final int flex;

  const _ScaleSegment({required this.color, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(color: color),
    );
  }
}
