import 'package:flutter/material.dart';

/// Maps WMO (World Meteorological Organization) weather codes to
/// human-readable descriptions and appropriate icons.
///
/// Open-Meteo uses WMO standard weather interpretation codes (0–99).
/// Full reference: https://open-meteo.com/en/docs
///
/// This utility is a central place to maintain weather presentation logic,
/// keeping it separate from the API layer and the UI layer.
class WeatherUtils {
  WeatherUtils._();

  /// Returns a human-readable description for a WMO weather code.
  static String getDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Foggy';
      case 48:
        return 'Rime Fog';
      case 51:
        return 'Light Drizzle';
      case 53:
        return 'Moderate Drizzle';
      case 55:
        return 'Dense Drizzle';
      case 56:
        return 'Freezing Drizzle';
      case 57:
        return 'Heavy Freezing Drizzle';
      case 61:
        return 'Slight Rain';
      case 63:
        return 'Moderate Rain';
      case 65:
        return 'Heavy Rain';
      case 66:
        return 'Freezing Rain';
      case 67:
        return 'Heavy Freezing Rain';
      case 71:
        return 'Slight Snowfall';
      case 73:
        return 'Moderate Snowfall';
      case 75:
        return 'Heavy Snowfall';
      case 77:
        return 'Snow Grains';
      case 80:
        return 'Slight Showers';
      case 81:
        return 'Moderate Showers';
      case 82:
        return 'Violent Showers';
      case 85:
        return 'Slight Snow Showers';
      case 86:
        return 'Heavy Snow Showers';
      case 95:
        return 'Thunderstorm';
      case 96:
        return 'Thunderstorm with Hail';
      case 99:
        return 'Severe Thunderstorm';
      default:
        return 'Unknown';
    }
  }

  /// Returns an appropriate [IconData] for a WMO weather code.
  /// [isDay] determines whether to use sun or moon variants.
  static IconData getIcon(int code, {bool isDay = true}) {
    // Clear
    if (code == 0 || code == 1) {
      return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    }
    // Partly cloudy
    if (code == 2) {
      return isDay
          ? Icons.wb_cloudy_rounded
          : Icons.nights_stay_rounded;
    }
    // Overcast
    if (code == 3) {
      return Icons.cloud_rounded;
    }
    // Fog
    if (code == 45 || code == 48) {
      return Icons.foggy;
    }
    // Drizzle
    if (code >= 51 && code <= 57) {
      return Icons.grain_rounded;
    }
    // Rain
    if (code >= 61 && code <= 67) {
      return Icons.water_drop_rounded;
    }
    // Snow
    if (code >= 71 && code <= 77) {
      return Icons.ac_unit_rounded;
    }
    // Rain showers
    if (code >= 80 && code <= 82) {
      return Icons.shower_rounded;
    }
    // Snow showers
    if (code >= 85 && code <= 86) {
      return Icons.ac_unit_rounded;
    }
    // Thunderstorm
    if (code >= 95 && code <= 99) {
      return Icons.thunderstorm_rounded;
    }
    // Default
    return Icons.wb_cloudy_rounded;
  }

  /// Returns a short label suitable for compact displays (e.g., hourly cards).
  static String getShortDescription(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Cloudy';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 57) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Showers';
    if (code >= 85 && code <= 86) return 'Snow';
    if (code >= 95 && code <= 99) return 'Storm';
    return 'Unknown';
  }

  /// Returns the wind direction as a compass label (N, NE, E, etc.)
  /// from a degree value (0–360).
  static String getWindDirection(double degrees) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW',
    ];
    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }
}
