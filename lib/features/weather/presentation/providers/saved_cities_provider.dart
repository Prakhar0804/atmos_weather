import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/location_model.dart';

/// Manages a list of saved/favourite cities, persisted in SharedPreferences.
///
/// ### How it works:
/// - Cities are stored as a JSON-encoded list of [LocationModel] objects.
/// - The provider loads saved cities on initialization.
/// - Widgets can add, remove, or reorder saved cities.
///
/// ### Interview talking point:
/// We serialize cities to JSON and store them in SharedPreferences rather than
/// using a full database (like Hive or SQLite) because the dataset is small
/// and the schema is simple. For a production app with hundreds of entries,
/// we'd use a proper database.

/// Provider for the list of saved cities.
final savedCitiesProvider =
    StateNotifierProvider<SavedCitiesNotifier, List<LocationModel>>((ref) {
  return SavedCitiesNotifier();
});

class SavedCitiesNotifier extends StateNotifier<List<LocationModel>> {
  static const _key = 'saved_cities';

  SavedCitiesNotifier() : super([]) {
    _loadCities();
  }

  /// Loads saved cities from SharedPreferences.
  Future<void> _loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      state = jsonList
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  /// Saves the current city list to SharedPreferences.
  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.map((c) => c.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  /// Adds a city to the saved list (if not already present).
  Future<void> addCity(LocationModel city) async {
    // Prevent duplicates by checking the location ID
    if (state.any((c) => c.id == city.id)) return;
    state = [...state, city];
    await _saveCities();
  }

  /// Removes a city from the saved list by its ID.
  Future<void> removeCity(int cityId) async {
    state = state.where((c) => c.id != cityId).toList();
    await _saveCities();
  }

  /// Checks if a city is already saved.
  bool isCitySaved(int cityId) {
    return state.any((c) => c.id == cityId);
  }
}
