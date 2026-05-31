import 'package:flutter/material.dart';

/// Curated color palette and weather-condition-based gradients.
///
/// The app background dynamically shifts its gradient based on the current
/// weather code (WMO standard) and whether it's day or night.
class AppColors {
  AppColors._();

  // ── Brand Colors ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color accent = Color(0xFF00D9FF);

  // ── Surface Colors ────────────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color lightSurface = Color(0xFFF0F4FF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // ── Glassmorphism Overlays ────────────────────────────────────────────
  static const Color glassWhite = Color(0x26FFFFFF); // 15% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
  static const Color glassDark = Color(0x33000000); // 20% black
  static const Color glassBorderDark = Color(0x1AFFFFFF); // 10% white

  // ── Text Colors ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textTertiary = Color(0x80FFFFFF); // 50% white
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textDarkSecondary = Color(0xFF4A4A6A);

  // ── Weather Gradient Maps ─────────────────────────────────────────────
  // Each weather condition maps to a pair of gradients [top, bottom].

  /// Clear sky during daytime — warm, inviting amber-to-blue
  static const List<Color> sunnyDay = [
    Color(0xFF2196F3),
    Color(0xFF64B5F6),
    Color(0xFFFFA726),
  ];

  /// Clear sky at night — deep indigo cosmos
  static const List<Color> clearNight = [
    Color(0xFF0D1B2A),
    Color(0xFF1B2838),
    Color(0xFF2C3E6B),
  ];

  /// Cloudy day — muted slate with teal hints
  static const List<Color> cloudyDay = [
    Color(0xFF546E7A),
    Color(0xFF78909C),
    Color(0xFF90A4AE),
  ];

  /// Cloudy night — deep grey-blue
  static const List<Color> cloudyNight = [
    Color(0xFF1A1A2E),
    Color(0xFF2D2D44),
    Color(0xFF3D3D5C),
  ];

  /// Rainy conditions — moody deep blue-purple
  static const List<Color> rainy = [
    Color(0xFF1A237E),
    Color(0xFF283593),
    Color(0xFF3949AB),
  ];

  /// Thunderstorm — dramatic dark purple
  static const List<Color> thunderstorm = [
    Color(0xFF1A0033),
    Color(0xFF2D1B69),
    Color(0xFF4A148C),
  ];

  /// Snowfall — icy white-blue
  static const List<Color> snowy = [
    Color(0xFF4FC3F7),
    Color(0xFF81D4FA),
    Color(0xFFB3E5FC),
  ];

  /// Foggy/misty — soft grey
  static const List<Color> foggy = [
    Color(0xFF616161),
    Color(0xFF757575),
    Color(0xFF9E9E9E),
  ];

  /// Drizzle — light blue-grey
  static const List<Color> drizzle = [
    Color(0xFF37474F),
    Color(0xFF455A64),
    Color(0xFF607D8B),
  ];

  // ── Light Theme Gradients (softer versions) ───────────────────────────
  static const List<Color> lightSunny = [
    Color(0xFF42A5F5),
    Color(0xFF90CAF9),
    Color(0xFFFFCC80),
  ];

  static const List<Color> lightCloudy = [
    Color(0xFF90A4AE),
    Color(0xFFB0BEC5),
    Color(0xFFCFD8DC),
  ];

  static const List<Color> lightRainy = [
    Color(0xFF5C6BC0),
    Color(0xFF7986CB),
    Color(0xFF9FA8DA),
  ];

  /// Returns the appropriate gradient colors based on weather code and
  /// whether it's currently day or night.
  ///
  /// [weatherCode] follows the WMO standard (0–99).
  /// [isDay] is true for daytime, false for nighttime.
  static List<Color> getWeatherGradient(int weatherCode, bool isDay) {
    // Clear sky
    if (weatherCode == 0) {
      return isDay ? sunnyDay : clearNight;
    }
    // Mainly clear, partly cloudy
    if (weatherCode <= 3) {
      return isDay ? sunnyDay : clearNight;
    }
    // Fog
    if (weatherCode == 45 || weatherCode == 48) {
      return foggy;
    }
    // Drizzle
    if (weatherCode >= 51 && weatherCode <= 57) {
      return drizzle;
    }
    // Rain
    if (weatherCode >= 61 && weatherCode <= 67) {
      return rainy;
    }
    // Snow
    if (weatherCode >= 71 && weatherCode <= 77) {
      return snowy;
    }
    // Rain showers
    if (weatherCode >= 80 && weatherCode <= 82) {
      return rainy;
    }
    // Snow showers
    if (weatherCode >= 85 && weatherCode <= 86) {
      return snowy;
    }
    // Thunderstorm
    if (weatherCode >= 95 && weatherCode <= 99) {
      return thunderstorm;
    }
    // Default fallback
    return isDay ? cloudyDay : cloudyNight;
  }

  // ── AQI Level Colors ──────────────────────────────────────────────────
  static const Color aqiGood = Color(0xFF4CAF50);
  static const Color aqiModerate = Color(0xFFFFEB3B);
  static const Color aqiUnhealthySensitive = Color(0xFFFF9800);
  static const Color aqiUnhealthy = Color(0xFFF44336);
  static const Color aqiVeryUnhealthy = Color(0xFF9C27B0);
  static const Color aqiHazardous = Color(0xFF7B1FA2);

  /// Returns the color corresponding to the US AQI value.
  static Color getAqiColor(int aqi) {
    if (aqi <= 50) return aqiGood;
    if (aqi <= 100) return aqiModerate;
    if (aqi <= 150) return aqiUnhealthySensitive;
    if (aqi <= 200) return aqiUnhealthy;
    if (aqi <= 300) return aqiVeryUnhealthy;
    return aqiHazardous;
  }

  /// Returns a human-readable label for the US AQI value.
  static String getAqiLabel(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
}
