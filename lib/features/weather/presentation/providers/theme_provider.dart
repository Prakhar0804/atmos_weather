import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's theme mode (dark/light) using Riverpod.
///
/// ### How Riverpod works here:
/// - [themeProvider] is a `StateNotifierProvider` that exposes a [ThemeNotifier].
/// - Widgets can read the current theme with `ref.watch(themeProvider)`.
/// - Widgets can toggle the theme with `ref.read(themeProvider.notifier).toggleTheme()`.
/// - The selected theme is persisted to [SharedPreferences] so it survives app restarts.

/// The provider that the rest of the app uses to access theme state.
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

/// Notifier that manages dark mode state and persists it locally.
///
/// [state] is `true` for dark mode, `false` for light mode.
class ThemeNotifier extends StateNotifier<bool> {
  static const _key = 'is_dark_mode';

  ThemeNotifier() : super(true) {
    // Default to dark mode, then load saved preference
    _loadTheme();
  }

  /// Loads the saved theme preference from SharedPreferences.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true; // Default: dark mode
  }

  /// Toggles between dark and light mode, and saves the preference.
  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}
