import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated gradient background that transitions smoothly
/// when the weather condition changes.
///
/// Uses [AnimatedContainer] with a 1-second ease-in-out transition
/// so the background gracefully shifts colors when the user switches
/// cities or when weather data refreshes.
class DynamicBackground extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final Widget child;

  const DynamicBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.getWeatherGradient(weatherCode, isDay);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// A simpler gradient background for screens that don't have weather data yet
/// (like the search screen or initial loading).
class DefaultBackground extends StatelessWidget {
  final Widget child;

  const DefaultBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F3460),
          ],
        ),
      ),
      child: child,
    );
  }
}
