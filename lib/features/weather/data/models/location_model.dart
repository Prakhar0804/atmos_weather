/// Location model for the Open-Meteo Geocoding API response.
///
/// Represents a single search result from:
/// `https://geocoding-api.open-meteo.com/v1/search?name=<query>`
class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double? elevation;
  final String? country;
  final String? countryCode;
  final String? timezone;
  final String? admin1; // State/Province

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.elevation,
    this.country,
    this.countryCode,
    this.timezone,
    this.admin1,
  });

  /// Parses a single location from the geocoding API JSON.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      elevation: (json['elevation'] as num?)?.toDouble(),
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
      timezone: json['timezone'] as String?,
      admin1: json['admin1'] as String?,
    );
  }

  /// Returns a display-friendly label like "Berlin, Germany"
  String get displayName {
    final parts = <String>[name];
    if (admin1 != null && admin1!.isNotEmpty) parts.add(admin1!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// JSON serialization for saving to SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'country': country,
      'country_code': countryCode,
      'timezone': timezone,
      'admin1': admin1,
    };
  }
}
